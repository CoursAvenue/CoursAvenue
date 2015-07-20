class Pro::PaymentsController < Pro::ProController
  protect_from_forgery only: []
  layout 'admin'

  before_action :parse_extra_data, only: [:be2bill_placeholder, :be2bill_notification, :be2bill_confirmation]

  # POST /paiement/be2bill_placeholder
  # Called by Be2bill to integrate payment form
  def be2bill_placeholder
    params[:premium_type] = params[:EXTRADATA]['plan_type']
    @structure = Structure.friendly.find params[:CLIENTIDENT]
    render 'pro/payments/be2bill_placeholders/premium_account', layout: 'admin'
  end

  # POST /paiement/be2bill_notifications
  # Called by Be2bill to notify when a transaction is made
  def be2bill_notification
    # Sets CLIENT_IP to have it for subscription
    params[:CLIENT_IP] = request.remote_ip || Structure.friendly.find(params[:CLIENTIDENT]).main_contact.last_sign_in_ip
    PaymentNotification::Be2bill.create params: params, structure_id: params[:CLIENTIDENT], order_id: params[:ORDERID], product_type: 'premium_account'
    render text: 'OK'
  end

  # GET /paiement/be2bill_confirmation
  # Page on which user is redirected after BE2BILL payment
  # Payment confirmation page called by Be2bill
  # Redirect to payment confirmation in order to removes all the parameters from the URL
  def be2bill_confirmation
    @payer_type = 'be2bill'
    @structure = Structure.friendly.find params[:CLIENTIDENT]
    @premium_type = params[:EXTRADATA]['plan_type']
    render 'pro/payments/confirmations/premium_account', layout: 'admin'
  end

  # GET /paiement/paypal_confirmation
  # Callback for paypal
  def paypal_confirmation
    @payer_type = 'paypal'
    @structure         = Structure.friendly.find params[:structure_id]
    PaymentNotification::Paypal.create(params: params, structure_id: params[:structure_id])
    render template: 'pro/payments/confirmations/premium_account', layout: 'admin'
  end

  private

  def parse_extra_data
    params[:EXTRADATA] = JSON.parse(params[:EXTRADATA])
  end

  def layout_locals
    locals = { hide_menu: true }
    locals[:top_menu_header_class] = 'hidden'
    locals
  end
end
