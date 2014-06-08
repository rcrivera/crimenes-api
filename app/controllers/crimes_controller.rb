class CrimesController < ApplicationController

	skip_before_filter :verify_authenticity_token
  before_filter :cors_preflight_check
  after_filter :cors_set_access_control_headers
  before_action :connect_db

  include Mongo

  # For all responses in this controller, return the CORS access control headers.
  def cors_set_access_control_headers
    headers['Access-Control-Allow-Origin'] = '*'
    headers['Access-Control-Allow-Methods'] = 'POST, GET, OPTIONS'
    headers['Access-Control-Max-Age'] = "1728000"
  end

  # If this is a preflight OPTIONS request, then short-circuit the
  # request, return only the necessary headers and return an empty
  # text/plain.

  def cors_preflight_check
    headers['Access-Control-Allow-Origin'] = '*'
    headers['Access-Control-Allow-Methods'] = 'POST, GET, OPTIONS'
    headers['Access-Control-Allow-Headers'] = 'X-Requested-With, X-Prototype-Version'
    headers['Access-Control-Max-Age'] = '1728000'
  end

  def index
    polygon = JSON.parse(params[:polygon])
    from_date = DateTime.strptime(params[:from_date], '%Y-%m-%d')
    from_date = Time.utc(from_date.year, from_date.month, from_date.day)
    to_date = DateTime.strptime(params[:to_date], '%Y-%m-%d')
    to_date = Time.utc(to_date.year, to_date.month, to_date.day)
    week_day = "0".to_i

    recordset = @coll.find({ "$and" => [{"geometry.coordinates" => {"$within" => {"$polygon" => polygon}}}, {"properties.time" => {:$gte => from_date, :$lte => to_date}},{"properties.week_day"=>{:$gte => week_day, :$lte => week_day}} ]},:fields => {:_id => false})

    if is_geojson == 'true'
      murder_collection = {:type => "FeatureCollection", :features => []}
      rape_collection = {:type => "FeatureCollection", :features => []}
      theft_collection = {:type => "FeatureCollection", :features => []}
      aggression_collection = {:type => "FeatureCollection", :features => []}
      breakin_collection = {:type => "FeatureCollection", :features => []}
      misappropriation_collection = {:type => "FeatureCollection", :features => []}
      carjacking_collection = {:type => "FeatureCollection", :features => []}
      fire_collection = {:type => "FeatureCollection", :features => []}

      recordset.each do |record|
      case record["properties"]["crime_category"]
        when 1 #murder
          murder_collection[:features] << record
        when 2 #rape
          rape_collection[:features] << record
        when 3 #theft
          theft_collection[:features] << record
        when 4 #agression
          aggression_collection[:features] << record
        when 5 #breakin
          breakin_collection[:features] << record
        when 6 #misappropriation
          misappropriation_collection[:features] << record
        when 7 #carjacking
          carjacking_collection[:features] << record
        when 8 #fire
          fire_collection[:features] << record
        end
      end

      @feature_collection = {:murder => murder_collection, :rape => rape_collection, :theft => theft_collection, :aggression => aggression_collection, :break_in => breakin_collection, :misappropriation => misappropriation_collection, :carjacking => carjacking_collection, :fire => fire_collection}

    else
      @feature_collection = []
      recordset.each do |record|
        coordinates = [record['geometry']['coordinates'][1],record['geometry']['coordinates'][0]]
        @feature_collection << coordinates
      end
    end

	  respond_to do |format|
      format.json { render :json => @feature_collection }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def connect_db
      #mongo_client = MongoClient.new("ds029277.mongolab.com",29277)
      #db = mongo_client.db("heroku_app23683383")
      #auth = db.authenticate('admin', 'admin123')
      #@coll = db.collection("crimes")
      mongo_client = MongoClient.new("localhost")
      db = mongo_client.db("crimenes_api_development")
      @coll = db.collection("crimes")
    end
end

# Sample url request
# http://localhost:3000/crimes?polygon=[[-67.9809077,%2018.4054882],[-66.1122969,%2018.359121],[-66.0583415,%2018.3848264]]&from_date=2013-04-01&to_date=2014-04-22

