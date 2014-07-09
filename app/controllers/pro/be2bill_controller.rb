# encoding: utf-8
class Pro::Be2billController < Pro::ProController
  protect_from_forgery only: []

  layout 'admin'

  # POST Called by Be2bill to integrate payment form
  def placeholder
    params[:EXTRADATA] = JSON.parse(params[:EXTRADATA])
    params[:premium_type] = params[:EXTRADATA]['plan_type']
    @structure = Structure.find params[:CLIENTIDENT]
    render 'be2bill_placeholder'
  end

  # POST Called by Be2bill to notify for a transaction
  def transaction_notifications
    params[:EXTRADATA] = JSON.parse(params[:EXTRADATA])
    @structure = Structure.find params[:CLIENTIDENT]
    send_emails
    # Sets CLIENT_IP to have it for subscription
    params[:CLIENT_IP] = request.remote_ip || @structure.main_contact.last_sign_in_ip

    if params[:EXECCODE] == '0000'
      if params[:EXTRADATA]['renew'].present?
        subscription_plan = @structure.subscription_plan
      else
        subscription_plan = SubscriptionPlan.subscribe!(params[:EXTRADATA]['plan_type'], @structure, params)
      end
      @structure.orders.create(amount: subscription_plan.amount,
                               order_id: params[:ORDERID],
                               promotion_code_id: params[:EXTRADATA]['promotion_code_id'],
                               subscription_plan: subscription_plan)
    end

    render text: 'OK'
  end

  private

  # Send email when be2bill hits transaction notifications
  def send_emails
    AdminMailer.delay.be2bill_transaction_notifications(@structure, params)
    if params['EXECCODE'] != '0000'
      Bugsnag.notify(RuntimeError.new("Payment refused"), params)
      AdminMailer.delay.go_premium_fail(@structure, params)
      if params[:EXTRADATA]['renew'].present?
        AdminMailer.delay.subscription_renewal_failed(@structure, params)
      end
    else
      AdminMailer.delay.go_premium(@structure, params[:EXTRADATA]['plan_type'])
    end
  end
end
