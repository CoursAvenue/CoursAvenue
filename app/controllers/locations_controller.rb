class LocationsController < ApplicationController
  respond_to :json

  def index
    @locations = Location.search do
      fulltext params[:term]

      with     :shared, true

      paginate page: 1, per_page: 20
    end.results

    respond_to do |format|
      format.json { render json: @locations.to_json(include: [:city]) }
    end
  end
end
