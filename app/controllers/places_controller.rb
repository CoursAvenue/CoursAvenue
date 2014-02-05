# encoding: utf-8
class PlacesController < ApplicationController
  def show
    @place        = Place.find params[:id]
    redirect_to structure_url @place.structure, subdomain: 'www', status: 301
  end
end
