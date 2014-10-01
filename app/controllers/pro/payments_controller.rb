class Pro::PaymentsController < Pro::ProController
  protect_from_forgery only: []
  layout 'admin'

  before_action :parse_extra_data, only: [:be2bill_placeholder, :be2bill_notification, :be2bill_confirmation]

  # POST /paiement/be2bill_placeholder
  # Called by Be2bill to integrate payment form
  def be2bill_placeholder
    # The placeholder can be call for teacher (Premium accounts) OR users (Discovery pass)
    if params[:EXTRADATA]['product_type'] and params[:EXTRADATA]['product_type'] == 'discovery_pass'
      @user = User.find params[:CLIENTIDENT]
      render 'pro/payments/be2bill_placeholders/discovery_pass', layout: 'user_profile'
    else
      params[:premium_type] = params[:EXTRADATA]['plan_type']
      @structure = Structure.find params[:CLIENTIDENT]
      render 'pro/payments/be2bill_placeholders/premium_account', layout: 'admin'
    end
  end

  # POST /paiement/be2bill_notifications
  # Called by Be2bill to notify when a transaction is made
  def be2bill_notification
    # The placeholder can be call for teacher (Premium accounts) OR users (Discovery pass)
    if params[:EXTRADATA]['product_type'] and params[:EXTRADATA]['product_type'] == 'discovery_pass'
      # Sets CLIENT_IP to have it for subscription
      params[:CLIENT_IP] = request.remote_ip || User.find(params[:CLIENTIDENT]).last_sign_in_ip
      PaymentNotification::Be2bill.create params: params, user_id: params[:CLIENTIDENT], product_type: 'discovery_pass'
    else
      # Sets CLIENT_IP to have it for subscription
      params[:CLIENT_IP] = request.remote_ip || Structure.find(params[:CLIENTIDENT]).main_contact.last_sign_in_ip
      PaymentNotification::Be2bill.create params: params, structure_id: params[:CLIENTIDENT], order_id: params[:ORDERID], product_type: 'premium_account'
    end
    render text: 'OK'
  end

  # GET /paiement/be2bill_confirmation
  # Payment confirmation page called by Be2bill
  # Redirect to payment confirmation in order to removes all the parameters from the URL
  def be2bill_confirmation
    @payer_type = 'be2bill'
    if params[:EXTRADATA]['product_type'] and params[:EXTRADATA]['product_type'] == 'discovery_pass'
      @user = User.find params[:CLIENTIDENT]
      render 'pro/payments/confirmations/discovery_pass', layout: 'user_profile'
    else
      @structure = Structure.find params[:CLIENTIDENT]
      @premium_type = params[:EXTRADATA]['plan_type']
      render 'pro/payments/confirmations/premium_account', layout: 'admin'
    end
  end

  # GET /paiement/paypal_confirmation
  # Callback for paypal
  def paypal_confirmation
    @payer_type = 'paypal'
    @structure         = Structure.find params[:structure_id]
    PaymentNotification::Paypal.create(params: params, structure_id: params[:structure_id])
    render template: 'confirmations/premium_account', layout: 'admin'
  end

  def paypal_notifications
    Bugsnag.notify(RuntimeError.new("Paypal notification"), params)
  end

  private

  def parse_extra_data
    params[:EXTRADATA] = JSON.parse(params[:EXTRADATA])
  end

end
