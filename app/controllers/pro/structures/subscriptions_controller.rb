class Pro::Structures::SubscriptionsController < Pro::ProController
  before_action :authenticate_pro_admin!, :set_structure

  layout 'admin'

  def index
    if @structure.subscribed?
      @subscription  = @structure.subscription.decorate
    else
      @monthly_plans = Subscriptions::Plan.monthly.decorate
      @yearly_plans  = Subscriptions::Plan.yearly.decorate

      @plans = []

      [@monthly_plans, @yearly_plans].each do |plans_by_period|
        plans_by_period.each_with_index do |plan, index|
          @plans[index] ||= []
          @plans[index] << plan
        end
      end
    end
  end

  def create
    plan  = Subscriptions::Plan.find(params[:plan_id])
    token = params[:stripe_token]

    respond_to do |format|
      if (@subscription = plan.create_subscription!(@structure, token)).present?
        format.html { redirect_to pro_structure_subscriptions_path(@structure),
                      notice: 'Votre abonnement a été créé avec succés' }
      else
        format.html { redirect_to pro_structure_subscriptions_path(@structure),
                      error: "Erreur lors de la création de l'abonnement, veuillez rééssayer.",
                      status: 400 }
      end
    end
  end

  private

  def set_structure
    @structure = Structure.find(params[:structure_id])
  end
end
