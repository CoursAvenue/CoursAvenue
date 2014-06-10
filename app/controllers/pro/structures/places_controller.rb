# encoding: utf-8
class Pro::Structures::PlacesController < InheritedResources::Base
  layout 'admin'

  before_action :authenticate_pro_admin!
  belongs_to :structure
  load_and_authorize_resource :structure, find_by: :slug

  def ask_for_deletion
    @structure = Structure.friendly.find params[:structure_id]
    @place     = @structure.places.find params[:id]
    if request.xhr?
      render layout: false
    end
  end

  def edit
    @structure = Structure.friendly.find params[:structure_id]
    @place     = @structure.places.find params[:id]
    @place.contacts.build if @place.contacts.empty?
    respond_to do |format|
      if request.xhr?
        format.html { render partial: 'form', layout: false }
      else
        format.html
      end
    end
  end

  def new
    @structure      = Structure.friendly.find params[:structure_id]
    @place          = @structure.places.build type: params[:type]
    @gmap_center    = Gmaps4rails.build_markers(@structure) do |structure, marker|
      marker.lat structure.latitude
      marker.lng structure.longitude
    end

    if @structure.places.map { |p| p.contacts }.flatten.any?
      @place.contacts << @structure.places.map { |p| p.contacts }.flatten.first.dup
    else
      @place.contacts.build
    end
    respond_to do |format|
      if request.xhr?
        format.html { render partial: 'form', layout: false }
      else
        format.html
      end
    end
  end

  def index
    index! do |format|
      @place_coordinates = Gmaps4rails.build_markers(@structure.places) do |place, marker|
        marker.lat place.latitude
        marker.lng place.longitude
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
        format.js
      else
        format.html { render action: :new }
        format.js
      end
    end
  end

  def update
    @structure = Structure.friendly.find params[:structure_id]
    @place     = @structure.places.find params[:id]
    respond_to do |format|
      if @place.update_attributes params[:place]
        format.html { redirect_to (params[:return_to] || pro_structure_places_path(@structure)), notice: 'Le lieu à bien été créé' }
        format.js
      else
        format.html { render action: :new }
        format.js
      end
    end
  end

  def destroy
    destroy! do |success, failure|
      success.html { redirect_to pro_structure_places_path(@structure) }
      success.js
    end
  end
end
