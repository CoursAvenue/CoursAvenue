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

  def edit_infos
    @structure = Structure.friendly.find params[:structure_id]
    @place     = @structure.places.find params[:id]
    render layout: false
  end

  def edit
    @structure = Structure.friendly.find params[:structure_id]
    @place     = @structure.places.find params[:id]
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
      get_places_coordinates
      format.html
    end
  end

  def create
    @structure = Structure.friendly.find params[:structure_id]
    @place     = @structure.places.build params[:place]
    respond_to do |format|
      if @place.save
        get_places_coordinates
        format.html { redirect_to (params[:return_to] || pro_structure_places_path(@structure)), notice: 'Le lieu a bien été créé' }
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
        get_places_coordinates
        format.html { redirect_to (params[:return_to] || pro_structure_places_path(@structure)), notice: 'Le lieu a bien été modifié' }
        format.js
      else
        format.html { render action: :new }
        format.js
      end
    end
  end

  def destroy
    destroy! do |success, failure|
      get_places_coordinates
      success.html { redirect_to pro_structure_places_path(@structure) }
      success.js
    end
  end

  private

  def get_places_coordinates
    @places_latlng = @structure.places.map do |place|
      place.to_react_json
    end
  end
end
