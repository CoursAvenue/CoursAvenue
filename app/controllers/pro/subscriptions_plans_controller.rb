class Pro::SubscriptionsPlansController < Pro::ProController
  before_action :authenticate_pro_super_admin!

  def index
    # @monthly_plans = Subscriptions::Plan.monthly
    # @yearly_plans  = Subscriptions::Plan.yearly
    @plans = Subscriptions::Plan.all
  end

  # TODO: Find an elegant way to have the amount in cents.
  def new
    @plan = Subscriptions::Plan.new

    render layout: false
  end

  def create
    @plan = Subscriptions::Plan.new(permitted_params)

    respond_to do |format|
      if @plan.save
        # format.html { redirect_to pro_subscriptions_plans_path, notice: 'Offre bien créé', status: 201 }
      else
        # format.html { render action: :new }
      end
    end

  end

  private

  def permitted_params
    params.require(:subscriptions_plan).permit(:name, :amount, :interval)
  end
end
