# encoding: utf-8
class Reservation::StructuresController < StructureWebsiteController

  def show
    @structure           = Structure.friendly.find(params[:id])
    @structure_decorator = @structure.decorate
    @city                = @structure.city
  end

  def reviews
    @reviews = @structure.comments
  end
end
