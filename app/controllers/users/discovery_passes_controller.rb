# encoding: utf-8
class Users::DiscoveryPassesController < Pro::ProController

  before_action :authenticate_user!
  load_and_authorize_resource :user, find_by: :slug

  layout 'user_profile'

  def index
  end

  # GET etablissements/:structure_id/abonnements/new
  def new
    # @structure.send_promo_code! unless @structure.promo_code_sent?
    extra_data = {}
    @discovery_pass = @user.discovery_passes.build

    @be2bill_description = "Pass découverte"

    @order_id = DiscoveryPass.next_order_id_for_user(@user)
    @be2bill_params = {
      'AMOUNT'        => @discovery_pass.amount_for_be2bill,
      'CLIENTIDENT'   => @user.id,
      'CLIENTEMAIL'   => @user.email,
      'CREATEALIAS'   => 'yes',
      'DESCRIPTION'   => @be2bill_description,
      'IDENTIFIER'    => ENV['BE2BILL_LOGIN'],
      'OPERATIONTYPE' => 'payment',
      'ORDERID'       => @order_id,
      'VERSION'       => '2.0',
      'EXTRADATA'     => extra_data.merge({ promotion_code_id: @promotion_code.try(:id), product_type: 'discovery_pass'}).to_json
    }
    @be2bill_params['HASH'] = DiscoveryPass.hash_be2bill_params @be2bill_params
  end

end
