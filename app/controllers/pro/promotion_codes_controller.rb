# encoding: utf-8
class Pro::PromotionCodesController < Pro::ProController
  before_action :authenticate_pro_super_admin!

  layout 'admin'

  def index
    @promotion_codes = PromotionCode.all
  end

  def new
    @promotion_code = PromotionCode.new
  end

  def edit
    @promotion_code = PromotionCode.find params[:id]
  end

  def create
    @promotion_code = PromotionCode.new params[:promotion_code]
    respond_to do |format|
      if @promotion_code.save
        format.html { redirect_to pro_promotion_codes_path }
      else
        format.html { render action: :new }
      end
    end
  end

  def update
    @promotion_code = PromotionCode.find params[:id]
    respond_to do |format|
      if @promotion_code.update_attributes params[:promotion_code]
        format.html { redirect_to pro_promotion_codes_path }
      else
        format.html { render action: :edit }
      end
    end
  end

  def destroy
    @promotion_code = PromotionCode.find params[:id]
    @promotion_code.cancel!
    respond_to do |format|
      format.html { redirect_to pro_promotion_codes_path }
    end
  end

end
