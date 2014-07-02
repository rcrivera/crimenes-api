class LoaderioController < ApplicationController
  def index
	  respond_to do |format|
	    format.html { render :text => 'loaderio-eee279776145ab21ff2757756fe8de34' }
	  end
  end
end
