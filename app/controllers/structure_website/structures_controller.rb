# encoding: utf-8
class StructureWebsite::StructuresController < StructureWebsiteController
  include FilteredSearchProvider

  def show
    @structure           = Structure.friendly.find(params[:id])
    @structure_decorator = @structure.decorate
    @place_ids           = @structure.places.includes(:city).map(&:id)
    @city                = @structure.city
  end

  def reviews
    @reviews = @structure.comments
  end
end
