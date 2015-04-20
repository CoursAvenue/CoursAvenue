# encoding: utf-8
class Structures::PlacesController < ApplicationController

  def index
    @structure = Structure.friendly.find params[:structure_id]
    @places = @structure.places
    respond_to do |format|
      format.json { render json: @places }
    end
  end
end
