# encoding: utf-8
class Pro::PlacesController < Pro::ProController
  #before_filter :authenticate_admin_user!
  layout 'admin'

  def index
    @structure = Structure.find params[:structure_id]
    @places    = @structure.places
    @places    = [Place.new] if @places.empty?
  end
end
