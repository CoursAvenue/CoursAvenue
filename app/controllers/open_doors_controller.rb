
# encoding: utf-8
class OpenDoorsController < ApplicationController
  include FilteredSearchProvider

  respond_to :json

  layout 'search'

  def index
    @app_slug = "open-doors-search"
    @subject  = filter_by_subject?

    params[:start_date]   = Date.parse('2014/04/05')
    params[:end_date]     = Date.parse('2014/04/06')
    params[:course_types] = ["open_course"]
    params[:page]         = 1 unless request.xhr?

    # Directly search plannings because it is by default filtered by dates
    @structures, @total = search_plannings

    @latlng = retrieve_location
    @models = jasonify @structures, jpo: true

    if params[:name].present?
      # Log search terms
      SearchTermLog.create(name: params[:name]) unless cookies["search_term_logs_#{params[:name]}"].present?
      cookies["search_term_logs_#{params[:name]}"] = {value: params[:name], expires: 12.hours.from_now}
    end

    respond_to do |format|
      format.json { render json: @structures,
                           root: 'structures',
                           jpo: true,
                           each_serializer: StructureSerializer,
                           meta: { total: @total, location: @latlng }}
      format.html do
        render 'structures/index'
        cookies[:structure_search_path] = request.fullpath
      end
    end
  end

end
