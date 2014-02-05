
# encoding: utf-8
class OpenDoorsController < ApplicationController
  include FilteredSearchProvider

  respond_to :json

  layout :choose_layout

  def index
    @app_slug = "open-doors-search"
    @subject = filter_by_subject?

    params[:course_types] = ["open"]
    params[:page] = 1 unless request.xhr?

    if params_has_planning_filters?
      @structures, @total = search_plannings
    else
      @structures, @total = search_structures
    end

    @latlng = retrieve_location
    @models = jasonify @structures

    if params[:name].present?
      # Log search terms
      SearchTermLog.create(name: params[:name]) unless cookies["search_term_logs_#{params[:name]}"].present?
      cookies["search_term_logs_#{params[:name]}"] = {value: params[:name], expires: 12.hours.from_now}
    end

    respond_to do |format|
      format.json { render json: @structures,
                           root: 'structures',
                           each_serializer: StructureSerializer,
                           meta: { total: @total, location: @latlng }}
      format.html do
        render 'structures/index'
        cookies[:structure_search_path] = request.fullpath
      end
    end
  end

  private

  def choose_layout
    if action_name == 'index'
      'search'
    else
      'users'
    end
  end

end
