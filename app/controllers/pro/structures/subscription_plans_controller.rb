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

  def paypal_express_checkout

    paypal_recurring_payment = PayPal::Recurring.new({
      :return_url   => paypal_confirmation_pro_payments_url(structure_id: @structure.id, plan_type: params[:plan_type], subdomain: CoursAvenue::Application::PRO_SUBDOMAIN),
      :cancel_url   => paypal_confirmation_pro_payments_url(structure_id: @structure.id, plan_type: params[:plan_type], cancel: true, subdomain: CoursAvenue::Application::PRO_SUBDOMAIN),
      # :ipn_url      => paypal_notification_pro_payments_url(structure_id: @structure.id, plan_type: params[:plan_type], ipn: true, subdomain: CoursAvenue::Application::PRO_SUBDOMAIN),
      :description  => "CoursAvenue Premium - #{SubscriptionPlan::PLAN_TYPE_DESCRIPTION[params[:plan_type]]}",
      :amount       => SubscriptionPlan::PLAN_TYPE_PRICES[params[:plan_type]].to_f.to_s,
      :currency     => "EUR"
    })

    response = paypal_recurring_payment.checkout
    redirect_to response.checkout_url if response.valid?
  end

end
