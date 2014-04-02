class CrimesController < ApplicationController

  def index
  	location = [-67.131790, 18.001448]

  	sju = [-66.0583415, 18.3848264]
  	gua = [-66.1122969, 18.359121]
  	car = [-67.9809077, 18.4054882]




  	#@crimes = Crime.where("property.time" => {:$gte => Time.utc(2013, 4, 1), :$lte => Time.now.utc})

  	#@crimes = Crime.where("geometry.coordinates" => {"$within" => {"$box" => [sju, gua, car]}})


  	#box = [sju, gua]

  	@crimes = Crime.where({"geometry.coordinates" => {"$within" => {"$polygon" => [sju, gua, car]}}})

    respond_to do |format|
      format.json { render :json => @crimes }
    end
  end

end





#polygon
#ul -67.131790, 18.476211
#dl -67.131790, 18.001448
#ur -65.640396, 18.476211
#dr -65.640396, 18.001448

#  	@crimes = Crime.where("property.time" => {:$gte => Time.utc(2013, 2, 1), :$lte => Time.now.utc}).geo_near(location).max_distance(1000).spherical

#@crimes = Crime.where("property.time" => {:$gte => Time.utc(2013, 2, 1), :$lte => Time.now.utc}).geo_near(location).max_distance(1000).spherical.max_distance.distance_multiplier(29)