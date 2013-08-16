# encoding: utf-8
class Pro::PlacesController < InheritedResources::Base
  before_filter :authenticate_pro_admin!
  layout 'admin'
  belongs_to :structure
  load_and_authorize_resource :structure, except: [:index]

  def new
    @place = Place.new
    @place.contacts.build
  end

  def index
    index! do |format|
      @locations = @structure.locations
      format.html
    end
  end

  def create
    create! do |success, failure|
      success.html { redirect_to (params[:from] or pro_structure_places_path(@structure)), notice: 'Le lieu à bien été créé' }
    end
  end

  def update
    update! do |success, failure|
      success.html { redirect_to pro_structure_places_path(@structure), notice: 'Le lieu à bien été mis à jour' }
    end
  end

  def destroy
    destroy! do |success, failure|
      success.html { redirect_to pro_structure_places_path(@structure) }
    end
  end
end
