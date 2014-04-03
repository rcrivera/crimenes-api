class CrimesController < ApplicationController

  def index
  	begin  
	    polygon = JSON.parse(params[:polygon])
	  	from_date = DateTime.strptime(params[:from_date], '%Y-%m-%d')
	  	to_date = DateTime.strptime(params[:to_date], '%Y-%m-%d')

	  	@crimes = Crime.where({"geometry.coordinates" => {"$within" => {"$polygon" => polygon}}}).and("property.time" => {:$gte => from_date, :$lte => Time.now.utc}) 
	  rescue  
	    @crimes = nil
	  end  
	  respond_to do |format|
      format.json { render :json => @crimes }
    end
  end
end

# Sample url request
# http://localhost:3000/crimes?polygon=[[-67.9809077,%2018.4054882],[-66.1122969,%2018.359121],[-66.0583415,%2018.3848264]]&from_date=2013-04-01&to_date=2014-04-22