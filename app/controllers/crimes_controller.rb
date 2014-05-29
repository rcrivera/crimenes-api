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
    is_geojson = params[:is_geojson]
    polygon = JSON.parse(params[:polygon])
    from_date = DateTime.strptime(params[:from_date], '%Y-%m-%d')
    from_date = Time.utc(from_date.year, from_date.month, from_date.day)
    to_date = DateTime.strptime(params[:to_date], '%Y-%m-%d')
    to_date = Time.utc(to_date.year, to_date.month, to_date.day)
    #Rails.logger.info to_date
    recordset = @coll.find({ "$and" => [{"geometry.coordinates" => {"$within" => {"$polygon" => polygon}}}, {"properties.time" => {:$gte => from_date, :$lte => to_date}}]},:fields => {:_id => false})

    if is_geojson
      @feature_collection = {:type => "FeatureCollection", :features => recordset}
    else
      @feature_collection = []
      recordset.each do |record|
        @feature_collection << record['geometry']['coordinates']
      end
    end

	  respond_to do |format|
      format.json { render :json => @feature_collection }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def connect_db
      mongo_client = MongoClient.new("ds029277.mongolab.com",29277)
      db = mongo_client.db("heroku_app23683383")
      auth = db.authenticate('admin', 'admin123')
      @coll = db.collection("crimes")
    end
end

# Sample url request
# http://localhost:3000/crimes?polygon=[[-67.9809077,%2018.4054882],[-66.1122969,%2018.359121],[-66.0583415,%2018.3848264]]&from_date=2013-04-01&to_date=2014-04-22

