# encoding: utf-8
class Pro::Be2billController < Pro::ProController
  protect_from_forgery only: []

  layout 'admin'

  # POST Called by Be2bill to integrate payment form
  def placeholder
    params[:premium_type] = SubscriptionPlan.premium_type_from_be2bill_amount params[:AMOUNT]
    @structure = Structure.find params[:CLIENTIDENT]
    render 'be2bill_placeholder'
  end

  # POST Called by Be2bill to notify for a transaction
  def transaction_notifications
    @structure = Structure.find params[:CLIENTIDENT]
    AdminMailer.delay.be2bill_transaction_notifications(@structure, params)

    if params['EXECCODE'] != '0000'
      Bugsnag.notify(RuntimeError.new("Payment refused"), params)
      AdminMailer.delay.go_premium_fail(@structure, params)
    else
      AdminMailer.delay.go_premium(@structure, SubscriptionPlan.premium_type_from_be2bill_amount(params[:AMOUNT]))
    end

    # Only create an order if there is no existing one with this ID
    # Prevents from reloading the page and creating another order
    params[:CLIENT_IP] = request.remote_ip || @structure.main_contact.last_sign_in_ip
    plan_type = SubscriptionPlan.premium_type_from_be2bill_amount(params[:AMOUNT]).to_sym
    if params[:EXECCODE] == '0000'
      subscription_plan = SubscriptionPlan.subscribe!(plan_type, @structure, params)
      @structure.orders.create(amount: subscription_plan.amount,
                               order_id: params[:ORDERID],
                               promotion_code_id: JSON.parse(params[:EXTRADATA])['promotion_code_id'],
                               subscription_plan: subscription_plan)
    end

    render text: 'OK'
  end
end
