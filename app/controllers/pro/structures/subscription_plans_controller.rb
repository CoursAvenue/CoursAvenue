# encoding: utf-8
class Pro::Structures::SubscriptionPlansController < Pro::ProController

  before_action :authenticate_pro_admin!
  load_and_authorize_resource :structure, find_by: :slug

  layout 'admin'

  # GET member
  def ask_for_cancellation
    @subscription_plan = @structure.subscription_plans.find params[:id]
    if request.xhr?
      render layout: false
    end
  end

  def confirm_cancellation
    @subscription_plan = @structure.subscription_plans.find params[:id]
    if request.xhr?
      render layout: false
    end
  end

  def destroy
    @subscription_plan = @structure.subscription_plans.find params[:id]
    @subscription_plan.update_attributes params[:subscription_plan]
    @subscription_plan.cancel!
    redirect_to premium_pro_structure_path(@structure)
  end

  # PATCH on member
  def reactivate
    @subscription_plan = @structure.subscription_plans.find params[:id]
    @subscription_plan.reactivate!
    redirect_to premium_pro_structure_path(@structure)
  end

end
