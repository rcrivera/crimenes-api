require 'mongo'
require 'json'
require 'geocoder'

include Mongo

Geocoder.configure(
	lookup: :mapquest,
	:http_headers => { "Referer" => "https://*" },
	:api_key => "Fmjtd%7Cluur2g6ynl%2Cb0%3Do5-9az294",
	:timeout => 45
)

mongo_client = MongoClient.new("localhost")
db = mongo_client.db("crimenes_api_development")
db.drop_collection('crimes')

coll = db.collection("crimes")

# mongo_uri = "mongodb://rubyaccess:rubyaccess@ds029277.mongolab.com:29277/heroku_app23683383"
# db_name = mongo_uri[%r{/([^/\?]+)(\?|$)}, 1]
# client = MongoClient.from_uri(mongo_uri)
# db = client.db("heroku_app23683383")
# coll = db.collection("crimes")

json = File.read('crimes.json')
obj = JSON.parse(json)

obj['features'].each do |n|
	coordinates = [n['geometry']['coordinates'][0],n['geometry']['coordinates'][1]]
	city = nil 
	result = Geocoder.search(coordinates[1].to_s + ',' + coordinates[0].to_s).first
	if (result) 
    city = result.city
  end
    
	properties = n['properties']
	year = properties['fecha_delito'][0,4].to_i
	month = properties['fecha_delito'][5,2].to_i
	day = properties['fecha_delito'][8,2].to_i
	hour = properties['hora_delito'][0,2].to_i
	minute = properties['hora_delito'][3,2].to_i
	second = properties['hora_delito'][6,2].to_i
	tz_offset = "-04:00"

	time = Time.new(year, month, day, hour, minute, second, tz_offset)
	week_day = time.wday

	doc = {'type'=>'Feature', 'geometry' => {"type"=>"Point", "coordinates" => coordinates}, "properties" => {"crime_category" => properties['delito_id'], "time" => time, "week_day" => week_day, "city" => city }}

	id = coll.insert(doc)

	puts city

end

coll.create_index({geometry: "2dsphere"})
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


