# encoding: utf-8
class Pro::Structures::PlacesController < InheritedResources::Base
  before_action :authenticate_pro_admin!
  layout 'admin'
  belongs_to :structure
  load_and_authorize_resource :structure, except: [:index], find_by: :slug

  def edit
    @structure = Structure.friendly.find params[:structure_id]
    @place     = @structure.places.find params[:id]
    @place.contacts.build if @place.contacts.empty?
    @gmap_location  = Gmaps4rails.build_markers(@place.location) do |location, marker|
      marker.lat location.latitude
      marker.lng location.longitude
    end
  end

  def new
    @structure      = Structure.friendly.find params[:structure_id]
    @place          = @structure.places.build
    @place.location = Location.new
    @gmap_center  = Gmaps4rails.build_markers(@structure) do |structure, marker|
      marker.lat structure.latitude
      marker.lng structure.longitude
    end

    if @structure.places.map { |p| p.contacts }.flatten.any?
      @place.contacts << @structure.places.map { |p| p.contacts }.flatten.first.dup
    else
      @place.contacts.build
    end
  end

  def index
    index! do |format|
      @locations = Gmaps4rails.build_markers(@structure.locations) do |location, marker|
        marker.lat location.latitude
        marker.lng location.longitude
      end
      format.html
    end
  end

  def create
    @structure = Structure.friendly.find params[:structure_id]
    @place     = @structure.places.build params[:place]
    respond_to do |format|
      if @place.save
        format.html { redirect_to (params[:return_to] || pro_structure_places_path(@structure)), notice: 'Le lieu à bien été créé' }
      else
        format.html { render action: :new }
      end
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
