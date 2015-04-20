class Pro::Structures::SubscriptionsController < Pro::ProController
  before_action :authenticate_pro_admin!, :set_structure

  layout 'admin'

  def index
    @subscription  = @structure.subscription
    @monthly_plans = Subscriptions::Plan.monthly
    @yearly_plans  = Subscriptions::Plan.yearly
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
