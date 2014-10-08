# encoding: utf-8
class Users::DiscoveryPassesController < Pro::ProController

  before_action :authenticate_user!
  load_and_authorize_resource :user, find_by: :slug

  layout 'user_profile'

  # GET eleves/:user_id/pass-decouverte/:id
  def show
    @discovery_pass = @user.discovery_passes.find params[:id]
  end

  # GET eleves/:user_id/pass-decouverte/:id/ask_for_cancellation
  def ask_for_cancellation
    @discovery_pass = @user.discovery_passes.find params[:id]
    render layout: false
  end

  # PATCH eleves/:user_id/pass-decouverte/:id/confirm_cancellation
  def cancel
    @discovery_pass = @user.discovery_passes.find params[:id]
    @discovery_pass.update_attributes params[:discovery_pass]
    @discovery_pass.cancel!
    respond_to do |format|
      format.html { redirect_to user_discovery_pass_path(@user, @discovery_pass) }
    end
  end

  # PATCH eleves/:user_id/pass-decouverte/:id/reactivate
  def reactivate
    @discovery_pass = @user.discovery_passes.find params[:id]
    @discovery_pass.update_attributes canceled_at: false
    respond_to do |format|
      format.html { redirect_to user_discovery_pass_path(@user, @discovery_pass) }
    end
  end

  # GET etablissements/:structure_id/abonnements/checkout
  def new
    extra_data = {}
    @discovery_pass = @user.discovery_passes.build
    if params[:promo_code] and (sponsor = Sponsorship.where(promo_code: params[:promo_code]).first)
      @discovery_pass.sponsorship = sponsor
    elsif @user.sponsors.any?
      @discovery_pass.sponsorship = @user.sponsors.first
    end
    @be2bill_description = "Pass découverte"

    @order_id = Order::Pass.next_order_id_for(@user)
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

  # GET etablissements/:structure_id/abonnements/new
  def index
    if current_user.discovery_pass
      redirect_to user_participation_requests_path(current_user)
    end
  end

  protected

  def layout_locals
    locals = { hide_menu: true }
    locals[:top_menu_header_class] = 'relative on-top' if action_name == 'index'
    locals
  end
end
