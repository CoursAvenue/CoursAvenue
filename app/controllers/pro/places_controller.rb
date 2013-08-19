# encoding: utf-8
class Pro::PlacesController < InheritedResources::Base
  before_filter :authenticate_pro_admin!
  layout 'admin'
  belongs_to :structure
  load_and_authorize_resource :structure, except: [:index]

  def edit
    @structure      = Structure.find params[:structure_id]
    @place          = @structure.places.find params[:id]
    @place.contacts.build if @place.contacts.empty?
  end

  def new
    @structure      = Structure.find params[:structure_id]
    @place          = @structure.places.build
    @place.location = Location.new
    @place.contacts.build
  end

  def index
    index! do |format|
      @locations = @structure.locations
      format.html
    end
  end

  def create
    @structure = Structure.find params[:structure_id]
    @location  = Location.find params[:place][:location_attributes].delete(:id) if params[:place][:location_attributes].has_key? :id
    @place     = @structure.places.build params[:place]
    @place.location = @location if @location
    respond_to do |format|
      if @place.save
        format.html { redirect_to (params[:from] or pro_structure_places_path(@structure)), notice: 'Le lieu à bien été créé' }
      else
        format.html { render action: :new}
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
