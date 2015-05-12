# encoding: utf-8
class PlanningsController < ApplicationController
  def index
    @plannings = PlanningSearch.search({ lat:48.8592,
                                         lng: 2.3417,
                                         order_by: :start_date,
                                         start_date: Date.today,
                                         per_page: 20}).results
  end
end
