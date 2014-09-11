class Pro::PaymentsController < Pro::ProController
  protect_from_forgery only: []
  layout 'admin'

  # POST /paiement/be2bill_placeholder
  # Called by Be2bill to integrate payment form
  def be2bill_placeholder
    params[:EXTRADATA] = JSON.parse(params[:EXTRADATA])
    params[:premium_type] = params[:EXTRADATA]['plan_type']
    @structure = Structure.find params[:CLIENTIDENT]
    render 'be2bill_placeholder'
  end

  # POST /paiement/be2bill_notifications
  # Called by Be2bill to notify when a transaction is made
  def be2bill_notification
    # Sets CLIENT_IP to have it for subscription
    params[:CLIENT_IP] = request.remote_ip || Structure.find(params[:CLIENTIDENT]).main_contact.last_sign_in_ip
    PaymentNotification::Be2bill.create params: params, structure_id: params[:CLIENTIDENT], order_id: params[:ORDERID]

    render text: 'OK'
  end

  # GET /paiement/be2bill_confirmation
  # Payment confirmation page called by Be2bill
  # Redirect to payment confirmation in order to removes all the parameters from the URL
  def be2bill_confirmation
    @payer_type = 'be2bill'
    @structure         = Structure.find params[:CLIENTIDENT]
    params[:EXTRADATA] = JSON.parse(params[:EXTRADATA])
    @premium_type = params[:EXTRADATA]['plan_type']
    render 'confirmation'
  end

  # GET /paiement/paypal_confirmation
  # Callback for paypal
  def paypal_confirmation
    @payer_type = 'paypal'
    @structure         = Structure.find params[:structure_id]
    PaymentNotification::Paypal.create(params: params, structure_id: params[:structure_id])
    render 'confirmation'
  end

  def paypal_notifications
    Bugsnag.notify(RuntimeError.new("Paypal notification"), params)
  end

end
