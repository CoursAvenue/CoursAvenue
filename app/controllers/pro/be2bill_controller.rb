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
    # Sets CLIENT_IP to have it for subscription
    params[:CLIENT_IP] = request.remote_ip || Structure.find(params[:CLIENTIDENT]).main_contact.last_sign_in_ip
    B2billNotification.create params: params, structure_id: params[:CLIENTIDENT], order_id: params[:ORDERID]

    render text: 'OK'
  end

end
