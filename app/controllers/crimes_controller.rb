class CrimesController < ApplicationController

	skip_before_filter :verify_authenticity_token
  before_filter :cors_preflight_check
  after_filter :cors_set_access_control_headers

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
  	begin  
	    polygon = JSON.parse(params[:polygon])
	  	from_date = DateTime.strptime(params[:from_date], '%Y-%m-%d')
	  	to_date = DateTime.strptime(params[:to_date], '%Y-%m-%d')

	  	recordset = Crime.where({"geometry.coordinates" => {"$within" => {"$polygon" => polygon}}}).and("property.time" => {:$gte => from_date, :$lte => Time.now.utc})

      @feature_collection = {:type => "FeatureCollection", :features => []}
      recordset.each do |record|
        f = {:type => "Feature", :geometry => {:type => 'Point',:coordinates => record['geometry']['coordinates']}, :properties => {:delito_id => record['property']['delito_id'], :time => record['property']['time']}}
        @feature_collection[:features] << f
      end
	  rescue  
	    @feature_collection = nil
	  end  
	  respond_to do |format|
      format.json { render :json => @feature_collection }
    end
  end
end

# Sample url request
# http://localhost:3000/crimes?polygon=[[-67.9809077,%2018.4054882],[-66.1122969,%2018.359121],[-66.0583415,%2018.3848264]]&from_date=2013-04-01&to_date=2014-04-22