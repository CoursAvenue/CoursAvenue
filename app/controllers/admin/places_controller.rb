class Admin::PlacesController < Admin::AdminController
  def index
    @places = Place.includes(:structure).where(latitude: nil).
      page(params[:page] || 1).per(50)
  end
end
