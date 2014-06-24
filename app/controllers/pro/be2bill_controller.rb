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
    @structure = Structure.find params[:CLIENTIDENT] if params[:CLIENTIDENT]
    AdminMailer.delay.be2bill_transaction_notifications(@structure, params)
    render text: 'OK'
  end
end
