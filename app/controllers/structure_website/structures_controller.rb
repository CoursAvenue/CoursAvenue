# encoding: utf-8
class StructureWebsite::StructuresController < StructureWebsiteController
  include FilteredSearchProvider

  def show
    @structure           = Structure.friendly.find(params[:id])
    @structure_decorator = @structure.decorate
    @city                = @structure.city
    @return_to_url       = request.referer.present? ? request.referer : @structure.website
  end

  def reviews
    @reviews = @structure.comments
  end
end
