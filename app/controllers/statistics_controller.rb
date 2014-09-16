class StatisticsController < ApplicationController

  def create
    if params[:structure_ids] and !current_pro_admin
      params[:structure_ids].each do |structure_id|
        Metric.create_action(params[:action_type], structure_id, current_user, params[:fingerprint], request.ip, params[:infos])
      end
    end
    respond_to do |format|
      format.js { render nothing: true }
    end
  end
end
