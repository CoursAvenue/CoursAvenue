# encoding: utf-8
class Pro::PlacesController < InheritedResources::Base#Pro::ProController
  #before_filter :authenticate_admin_user!
  layout 'admin'
  belongs_to :structure
  load_and_authorize_resource :structure

  def create
    create! do |success, failure|
      success.html { redirect_to structure_places_path(@structure) }
    end
  end

  def update
    update! do |success, failure|
      success.html { redirect_to structure_places_path(@structure) }
    end
  end
end
