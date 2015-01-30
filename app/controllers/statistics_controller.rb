class StatisticsController < ApplicationController

  def create
    # if params[:structure_ids] and !current_pro_admin
    #   Metric.delay(queue: 'metric').create_action(params[:action_type], params[:structure_ids], params[:fingerprint], request.ip, params[:infos])
    # end
    respond_to do |format|
      format.js { render nothing: true }
    end
  end
end
