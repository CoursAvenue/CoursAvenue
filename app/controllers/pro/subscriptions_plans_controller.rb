class Pro::SubscriptionsPlansController < Pro::ProController
  before_action :authenticate_pro_super_admin!

  def index
    @monthly_plans = Subscriptions::Plan.monthly.decorate
    @yearly_plans  = Subscriptions::Plan.yearly.decorate
    @plans         = Subscriptions::Plan.all.decorate
  end

  def new
    @plan    = Subscriptions::Plan.new
    @edition = false

    if request.xhr?
      render layout: false
    end
  end

  def create
    @plan = Subscriptions::Plan.new(permitted_params)

    respond_to do |format|
      if @plan.save
        format.html { redirect_to pro_subscriptions_plans_path, notice: 'Offre bien créée', status: 201 }
        format.js
      else
        format.html { render action: :new }
        format.js
      end
    end
  end

  def edit
    @plan    = Subscriptions::Plan.find params[:id]
    @edition = true

    render layout: false
  end

  def update
    @plan = Subscriptions::Plan.find params[:id]

    respond_to do |format|
      if @plan.update_attributes permitted_params and @plan.update_stripe_plan!
        format.html { redirect_to pro_subscriptions_plans_path, notice: 'Offre bien mise a jour', status: 200 }
        format.js
      else
        format.html { render action: :new }
        format.js
      end
    end
  end

  def destroy
    @plan = Subscriptions::Plan.find params[:id]

    respond_to do |format|
      if @plan.delete_stripe_plan! and @plan.destroy
        format.html { redirect_to pro_subscriptions_plans_path,
                      notice: 'Offre supprimée.' }
      else
        format.html { redirect_to pro_subscriptions_plans_path,
                      error: "Erreur lors de la suppression de l'offre, veillez rééssayer." }
      end
    end

  end

  def subscriptions
    @plan          = Subscriptions::Plan.includes(:subscriptions).find(params[:id])
    @subscriptions = @plan.subscriptions

    render layout: false
  end

  private

  def permitted_params
    params.require(:subscriptions_plan).permit(:name, :public_name, :plan_type, :amount, :interval, :trial_period_days)
  end
end
