require 'mongo'
require 'json'

include Mongo

mongo_client = MongoClient.new("localhost")
db = mongo_client.db("crimenes_api_development")
coll = db.collection("crimes")

json = File.read('crimes.json')
obj = JSON.parse(json)

obj['features'].each do |n|
	coordinates = [n['geometry']['coordinates'][0],n['geometry']['coordinates'][1]]
	properties = n['properties']
	year = properties['fecha_delito'][0,4].to_i
	month = properties['fecha_delito'][5,2].to_i
	day = properties['fecha_delito'][8,2].to_i
	hour = properties['hora_delito'][0,2].to_i
	minute = properties['hora_delito'][3,2].to_i
	second = properties['hora_delito'][6,2].to_i
	tz_offset = "-04:00"

	time = Time.new(year, month, day, hour, minute, second, tz_offset)

	doc = { 'geometry' => {"type"=>"Point", "coordinates" => coordinates}, "property" => {"delito_id" => properties['delito_id'], "time" => time}}

	id = coll.insert(doc)

	puts id
end

#db.crimes.ensureIndex({geometry: "2dsphere"})
#db.runCommand( { geoNear: 'crimes', near: {type: "Point", coordinates: [-66.0585352796529, 18.42801979046167]}, spherical: true, maxDistance: 40})

#in Ruby db.command( { geoNear: 'crimes', near: {type: "Point", coordinates: [-66.0585352796529, 18.42801979046167]}, spherical: true, maxDistance: 40})

#db.command( { geoNear: 'crimes', near: {type: "Point", coordinates: [-66.0585352796529, 18.42801979046167]}, spherical: true, maxDistance: 40})

=begin
db.command(
    {
        geoNear: "crimes", 
        near: {type: "Point", coordinates: [-66.1585352796529, 18.42801979046167]},
        spherical: true,
        maxDistance: 1000,
        query: { "property.time" => {:$gte => Time.utc(2013, 3, 27), :$lte => Time.now.utc}}
    }
)
=end


