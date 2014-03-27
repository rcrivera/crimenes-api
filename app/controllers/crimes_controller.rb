class CrimesController < ApplicationController

  def index
    @crimes = Crime.all
    respond_to do |format|
      format.json { render :json => @crimes }
    end
  end


end
