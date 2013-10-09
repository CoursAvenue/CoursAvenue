class LocationsController < ApplicationController
  respond_to :json

  def index
    @locations = Location.search do
      fulltext params[:term]

      with     :shared, true

      paginate page: 1, per_page: 20
    end.results

    respond_to do |format|
      format.json { render json: @locations, meta: { total: @locations.count }, each_serializer: LocationSerializer }
    end
  end

end
