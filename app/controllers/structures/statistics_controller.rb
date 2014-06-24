class Structures::StatisticsController < ApplicationController

  def create
    @structure = Structure.find params[:structure_id]
    Statistic.create_action(params[:action_type], @structure.id, current_user, cookies[:fingerprint], request.ip, params[:infos]) unless current_pro_admin
    respond_to do |format|
      format.js { render nothing: true }
    end
  end
end
