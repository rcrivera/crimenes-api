class CrimesController < ApplicationController

  def index
  	location = [-66.0585352796529, 18.42801979046167]
  	@crimes = Crime.where("property.time" => {:$gte => Time.utc(2013, 4, 1), :$lte => Time.now.utc}).geo_near(location).max_distance(1000)
    respond_to do |format|
      format.json { render :json => @crimes }
    end
  end


end

