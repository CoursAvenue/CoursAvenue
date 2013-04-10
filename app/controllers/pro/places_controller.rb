# encoding: utf-8
class Pro::PlacesController < InheritedResources::Base#Pro::ProController
  before_filter :authenticate_pro_admin!
  layout 'admin'
  belongs_to :structure
  load_and_authorize_resource :structure

  def index
    index! do |format|
      if @structure.places.empty?
        format.html { redirect_to new_pro_structure_place_path(@structure) }
      end
    end
  end
  def create
    create! do |success, failure|
      success.html { redirect_to pro_structure_place_rooms_path(@structure, @place) }
    end
  end

  def update
    if params[:place].delete(:delete_image) == '1'
      resource.image.clear
    end
    if params[:place].delete(:delete_thumb_image) == '1'
      resource.thumb_image.clear
    end
    update! do |success, failure|
      success.html { redirect_to pro_structure_places_path(@structure) }
    end
  end

  def destroy
    destroy! do |success, failure|
      success.html { redirect_to pro_structure_places_path(@structure) }
    end
  end
end
