class Pro::Structures::SubscriptionsController < Pro::ProController
  before_action :authenticate_pro_admin!, :set_structure
  load_and_authorize_resource :structure, find_by: :slug

  layout 'admin'

  def index
    if @structure.subscription.present?
      @subscription = @structure.subscription.decorate
      @sponsorship  = Subscriptions::Sponsorship.where(token: @structure.sponsorship_token).first
    else
      token = session[:sponsorship_token] || params[:sponsorship_token] ||
        @structure.sponsorship_token

      @monthly_plans = ::Subscriptions::Plan.monthly.order('amount ASC').decorate
      @yearly_plans  = ::Subscriptions::Plan.yearly.order('amount ASC').decorate
      @sponsorship   = Subscriptions::Sponsorship.where(token: token).first
    end

    @sponsorship_token = @sponsorship.present? ? @sponsorship.token : nil
  end

  def create
    plan              = Subscriptions::Plan.find(subscription_plan_id_params[:plan_id])
    sponsorship_token = subscription_plan_id_params[:sponsorship_token]

    @subscription = plan.create_subscription!(@structure)

    if sponsorship_token.present?
      @structure.sponsorship_token = sponsorship_token
      @subscription.save
    end

    respond_to do |format|
      if @subscription.present? and @subscription.persisted?
        format.html { redirect_to pro_structure_subscriptions_path(@structure),
                      notice: 'Votre abonnement a été créé avec succés' }
      else
        format.html { redirect_to pro_structure_subscriptions_path(@structure),
                      error: "Erreur lors de la création de l'abonnement, veuillez rééssayer.",
                      status: 400 }
      end
    end
  end

  def confirm_choice
    if subscription_plan_id_params[:plan_id].present?
      @plan = Subscriptions::Plan.find(subscription_plan_id_params[:plan_id])
    else
      @plan = @structure.subscription.plan
    end

    @sponsorship = Subscriptions::Sponsorship.where(
      token: @structure.sponsorship_token).first

    if request.xhr?
      render layout: false
    end
  end

  def choose_plan_and_pay
    @monthly_plans = ::Subscriptions::Plan.monthly.order('amount ASC').decorate
    @yearly_plans  = ::Subscriptions::Plan.yearly.order('amount ASC').decorate
    @plan          = @structure.subscription.plan
    if request.xhr?
      render layout: false
    end
  end

  def confirm_cancellation
    @subscription = @structure.subscription

    if request.xhr?
      render layout: false
    end
  end

  def stripe_payment_form
    @subscription = @structure.subscription.decorate

    if request.xhr?
      render layout: false
    end
  end

  def destroy
    @subscription = @structure.subscription

    @subscription.update_attributes(params[:subscription])
    @subscription.cancel!

    redirect_to pro_structure_subscriptions_path(@structure), notice: 'Vous êtes maintenant désabonné'
  end

  def activate
    @subscription = @structure.subscription
    plan          = Subscriptions::Plan.find(subscription_plan_id_params[:plan_id])
    @subscription.plan = plan
    @subscription.save

    error_code_value = @subscription.charge!(stripe_token_params[:stripe_token],
            Subscriptions::Coupon.where(stripe_coupon_id: stripe_token_params[:promo_code]).first)

    respond_to do |format|
      if error_code_value.nil?
        format.html { redirect_to pro_structure_subscriptions_path(@structure), notice: 'Vous êtes maintenant abonné !' }
      else
        format.html { redirect_to pro_structure_subscriptions_path(@structure), notice: 'Vous êtes maintenant abonné !' }
      end
    end
  end

  def choose_new_plan
    @subscription  = @structure.subscription
    @monthly_plans = ::Subscriptions::Plan.monthly.order('amount ASC').decorate
    @yearly_plans  = ::Subscriptions::Plan.yearly.order('amount ASC').decorate

    if request.xhr?
      render layout: false
    end
  end

  def change_plan
    @subscription = @structure.subscription
    plan          = Subscriptions::Plan.find(subscription_plan_id_params[:plan_id])
    @subscription.change_plan!(plan)

    redirect_to pro_structure_subscriptions_path(@structure), notice: 'Votre abonnement a bién été changé'
  end

  def reactivate
    @subscription = @structure.subscription
    @subscription.reactivate!

    redirect_to pro_structure_subscriptions_path(@structure), notice: 'Vous êtes maintenant réabonné'
  end

  # PATCH accept_payments
  def accept_payments
    @managed_account_form = ManagedAccountForm.new(params[:managed_account_form])

    @managed_account_form.structure_id      = @structure.id
    @managed_account_form.tos_acceptance_ip = request.ip

    if @managed_account_form.save
      redirect_to website_planning_parameters_pro_structure_path(@structure),
        notice: 'Vos informations ont été reçus avec succès'
    else
      redirect_to website_planning_parameters_pro_structure_path(@structure),
        error: 'Une erreur est survenue, veuillez rééssayer.'
    end
  end

  # GET /pro/structures/subscriptions/accept_payments_form
  def accept_payments_form

    if request.xhr?
      render layout: false
    end
  end

  private

  def set_structure
    @structure = Structure.find(params[:structure_id])
  end

  def stripe_token_params
    params.require(:subscription).permit(:stripe_token, :sponsorship_token, :promo_code)
  end

  def subscription_plan_id_params
    params.permit(:plan_id, :coupon_code, :sponsorship_token)
  end
end
