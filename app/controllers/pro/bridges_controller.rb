# encoding: utf-8
class Pro::BridgesController < Pro::ProController
  before_action :authenticate_pro_super_admin!

  def update
    @bridge = EmailingSectionBridge.find params[:id]

    respond_to do |format|
      if @bridge.update_attributes params
        format.json { render nothing: true }
      else
        format.json { render json: { errors: @bridge.errors }, status: 422 }
      end
    end
  end
end
