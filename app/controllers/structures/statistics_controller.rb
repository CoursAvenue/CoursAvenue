class Structures::StatisticsController < ApplicationController

  def create
    Metric.delay(queue: 'metric').create_action(params[:action_type], params[:structure_id], params[:fingerprint], request.ip, params[:infos]) unless current_pro_admin
    respond_to do |format|
      format.js { render nothing: true }
    end
  end
end
