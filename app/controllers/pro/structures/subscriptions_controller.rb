class Pro::Structures::SubscriptionsController < Pro::ProController
  before_action :authenticate_pro_admin!, :set_structure

  layout 'admin'

  def index
    if @structure.subscription.present?
      @subscription = @structure.subscription.decorate
    else
      @monthly_plans = ::Subscriptions::Plan.monthly.order('amount ASC').decorate
      @yearly_plans  = ::Subscriptions::Plan.yearly.order('amount ASC').decorate
    end
  end

  def create
    plan        = Subscriptions::Plan.find(subscription_plan_id_params[:plan_id])
    coupon_code = params[:coupon_code]

    @subscription = plan.create_subscription!(@structure, coupon_code)

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

    error_code_value = @subscription.charge! stripe_token_params[:stripe_token]
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

    redirect_to pro_structure_subscriptions_path(@structure), notice: 'Vous êtes maintenant réabonné'
  end

  def reactivate
    @subscription = @structure.subscription
    @subscription.reactivate!

    redirect_to pro_structure_subscriptions_path(@structure), notice: 'Vous êtes maintenant réabonné'
  end

  private

  def set_structure
    @structure = Structure.find(params[:structure_id])
  end

  def stripe_token_params
    params.require(:subscription).permit(:stripe_token)
  end

  def subscription_plan_id_params
    params.permit(:plan_id)
  end
end
