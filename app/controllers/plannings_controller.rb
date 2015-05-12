# encoding: utf-8
class PlanningsController < ApplicationController
  def index
    search_params = { lat:48.8592, lng: 2.3417, order_by: :start_date,
                      start_date: Date.today, per_page: 20 }
    if params[:sort] == 'week-end'
      @plannings = PlanningSearch.search(search_params.merge(week_days: [0, 6],
                                                             start_date: Date.today.beginning_of_week(:sunday) + 1.week )).results
    else
      @plannings = PlanningSearch.search(search_params).results
    end
  end
end
