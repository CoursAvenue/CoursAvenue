# encoding: utf-8
class Pro::PlacesController < InheritedResources::Base
  before_filter :authenticate_pro_admin!
  layout 'admin'
  belongs_to :structure
  load_and_authorize_resource :structure, except: [:index]

  def index
    index! do |format|
      if @structure.places.empty?
        format.html { redirect_to new_pro_structure_place_path(@structure) }
      end
    end
  end

  def create
    if can? :create, Place
      create! do |success, failure|
        success.html { redirect_to pro_structure_places_path(@structure) }
      end
    else
      redirect_to pro_structure_places_path(@structure), alert: "Votre compte n'est pas encore activé, vous ne pouvez pas encore créer de lieu"
    end
  end

  def update
    if can? :edit, resource
      if params[:place].delete(:delete_image) == '1'
        resource.image.clear
      end
      if params[:place].delete(:delete_thumb_image) == '1'
        resource.thumb_image.clear
      end
      update! do |success, failure|
        success.html { redirect_to pro_structure_places_path(@structure) }
      end
    else
      redirect_to pro_structure_places_path(@structure), alert: "Votre compte n'est pas encore activé, vous ne pouvez pas éditer ce lieu"
    end
  end

  def destroy
    if can? :edit, resource
      destroy! do |success, failure|
        success.html { redirect_to pro_structure_places_path(@structure) }
      end
    else
      redirect_to pro_structure_places_path(@structure), alert: "Votre compte n'est pas encore activé, vous ne pouvez pas éditer ce lieu"
    end
  end
end
