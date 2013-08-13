# encoding: utf-8
class StructuresController < ApplicationController

  def show
    @structure      = Structure.find params[:id]
    @city           = @structure.city
    @places         = @structure.places
    @places_address = @places.to_gmaps4rails
    @courses        = @structure.courses.active
    @teachers       = @structure.teachers
    @medias         = @structure.medias
    @comments       = @structure.all_comments
    @comment        = @structure.comments.build
  end
end
