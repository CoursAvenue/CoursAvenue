# encoding: utf-8
class Pro::Structures::SubscriptionPlansController < Pro::ProController

  before_action :authenticate_pro_admin!
  load_and_authorize_resource :structure, find_by: :slug

  layout 'admin'

  # GET etablissements/:structure_id/premium
  def premium
    Statistic.create(structure_id: @structure.id, action_type: "structure_go_premium_premium_page", infos: request.referrer)
  end

  # GET etablissements/:structure_id/abonnements/:id
  def show
  end

  # GET etablissements/:structure_id/abonnements/new
  def new
    # @structure.send_promo_code! unless @structure.promo_code_sent?
    extra_data = {}
    # A subscription_plan_id will be passed when the user will want to reactivate his subscription
    if params[:subscription_plan_id] and @structure.subscription_plans.find(params[:subscription_plan_id])
      @subscription_plan = @structure.subscription_plans.find(params[:subscription_plan_id])
      @promotion_code = @subscription_plan.promotion_code if @subscription_plan.promotion_code
      extra_data[:renew] = true
    else
      @subscription_plan = SubscriptionPlan.new plan_type: params[:premium_type]
      if params[:promo_code]
        if (promotion_code = PromotionCode.where(code_id: params[:promo_code]).first) and promotion_code.still_valid?(@subscription_plan)
          @subscription_plan.promotion_code = promotion_code
        else
          flash[:error] = "Le code promo : #{params[:promo_code]} n'est pas valide"
        end
      end
    end
    AdminMailer.delay.wants_to_go_premium(@structure, @subscription_plan.plan_type)

    @be2bill_description = "Abonnement Premium CoursAvenue"

    @order_id = Order.next_order_id_for @structure
    @be2bill_params = {
      'AMOUNT'        => @subscription_plan.amount_for_be2bill,
      'CLIENTIDENT'   => @structure.id,
      'CLIENTEMAIL'   => @structure.main_contact.email,
      'CREATEALIAS'   => 'yes',
      'DESCRIPTION'   => @be2bill_description,
      'IDENTIFIER'    => ENV['BE2BILL_LOGIN'],
      'OPERATIONTYPE' => 'payment',
      'ORDERID'       => @order_id,
      'VERSION'       => '2.0',
      'EXTRADATA'     => extra_data.merge({ promotion_code_id: @promotion_code.try(:id), plan_type: @subscription_plan.plan_type }).to_json
    }
    @be2bill_params['HASH'] = SubscriptionPlan.hash_be2bill_params @be2bill_params
  end

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
    redirect_to pro_structure_subscription_plans_path(@structure)
  end

  # PATCH on member
  def reactivate
    @subscription_plan = @structure.subscription_plans.find params[:id]
    @subscription_plan.reactivate!
    redirect_to pro_structure_subscription_plans_path(@structure)
  end

  def paypal_express_checkout
    subscription_plan = SubscriptionPlan.new plan_type: params[:plan_type], promotion_code_id: params[:promotion_code_id]
    paypal_recurring_payment = PayPal::Recurring.new({
      :return_url   => paypal_confirmation_pro_payments_url(structure_id: @structure.id, plan_type: params[:plan_type], promotion_code_id: params[:promotion_code_id], subdomain: CoursAvenue::Application::PRO_SUBDOMAIN),
      :cancel_url   => paypal_confirmation_pro_payments_url(structure_id: @structure.id, plan_type: params[:plan_type], cancel: true, subdomain: CoursAvenue::Application::PRO_SUBDOMAIN),
      :ipn_url      => paypal_notification_pro_payments_url(structure_id: @structure.id, plan_type: params[:plan_type], ipn: true, subdomain: CoursAvenue::Application::PRO_SUBDOMAIN),
      :description  => "CoursAvenue Premium - #{SubscriptionPlan::PLAN_TYPE_DESCRIPTION[params[:plan_type]]}",
      :amount       => subscription_plan.amount.to_f.to_s,
      :currency     => "EUR"
    })

    response = paypal_recurring_payment.checkout
    redirect_to response.checkout_url if response.valid?
  end

end
