# encoding: utf-8
class StructuresWebsiteController < ApplicationController
  include FilteredSearchProvider

  before_action :load_structure

  layout 'structure_website'

  def index
  end

  def planning
    @structure = Structure.find request.subdomain
    @structure_decorator = @structure.decorate
    @place_ids           = @structure.places.map(&:id)
    @city                = @structure.city

    @similar_profiles = @structure.similar_profiles(18)
    @medias = @structure.medias.cover_first.videos_first
    @model = StructureShowSerializer.new(@structure, {
      structure:          @structure,
      unlimited_comments: false,
      query:              get_filters_params,
      place_ids:          @place_ids
    })

  end

  def reviews
    @reviews = @structure.comments
  end

  def medias
    @medias = @structure.medias
  end

  def contact
  end

  private

  def load_structure
    @structure = Structure.find request.subdomain
  end
end
