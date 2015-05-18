class Pro::SubscriptionsCouponsController < Pro::ProController
  before_action :authenticate_pro_super_admin!

  def index
    @coupons = Subscriptions::Coupon.all
  end

  def new
    @coupon  = Subscriptions::Coupon.new
    @showing = false

    if request.xhr?
      render layout: false
    end
  end

  def create
    @coupon = Subscriptions::Coupon.new(permitted_params)

    respond_to do |format|
      if @coupon.save
        format.html { redirect_to pro_subscriptions_coupons_path, notice: 'Code promo bien créé' }
        format.js
      else
        format.html { render action: :new }
        format.js
      end
    end
  end

  def show
    @coupon = Subscriptions::Coupon.find(params[:id])
    @showing = true

    if request.xhr?
      render layout: false
    end
  end

  # @params:
  #   id
  # GET /subscriptions_coupons/:id
  def check
    @coupon = Subscriptions::Coupon.where(stripe_coupon_id: params[:id]).first
    # Also check in Sponsorships
    if @coupon.nil?
      @coupon = Subscriptions::Sponsorship.where(token: params[:id]).first
      @coupon = Subscriptions::SponsorshipSerializer.new(@coupon)
    end
    respond_to do |format|
      format.json { render json: { coupon: (@coupon ? @coupon.to_json : nil) } }
    end
  end

  def destroy
    @coupon = Subscriptions::Coupon.find(params[:id])

    respond_to do |format|
      if @coupon.delete_stripe_coupon! and @coupon.destroy
        format.html { redirect_to pro_subscriptions_coupons_path,
                      notice: 'Code promo supprimé.' }
      else
        format.html { redirect_to pro_subscriptions_coupons_path,
                      error: "Erreur lors de la suppression du code promo, veuillez rééssayer." }
      end
    end
  end

  private

  def permitted_params
    params.require(:subscriptions_coupon).permit(:name, :amount, :duration, :duration_in_months, :stripe_coupon_id, :redeem_by)
  end
end
