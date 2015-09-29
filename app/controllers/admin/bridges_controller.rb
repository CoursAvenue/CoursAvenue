# encoding: utf-8
class Admin::BridgesController < Admin::AdminController
  before_action :authenticate_pro_super_admin!

  def update
    @bridge = EmailingSectionBridge.find(params[:id])

    respond_to do |format|
      if @bridge.update_attributes bridge_params
        format.json { render nothing: true }
      else
        format.json { render json: { errors: @bridge.errors }, status: 422 }
      end
    end
  end

  private

  def bridge_params
    params.require(:bridge).permit(
      :media_id, :subject_id, :subject_name, :review_id, :review_text, :review_custom, :city_text)
  end
end
