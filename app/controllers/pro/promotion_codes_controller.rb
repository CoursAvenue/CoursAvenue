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
    @promotion_code.save
    respond_to do |format|
      format.html { redirect_to pro_promotion_codes_path }
    end
  end

  def update
    @promotion_code = PromotionCode.find params[:id]
    @promotion_code.update_attributes params[:promotion_code]
    respond_to do |format|
      format.html { redirect_to pro_promotion_codes_path }
    end
  end

  def destroy
    @promotion_code = PromotionCode.find params[:id]
    @promotion_code.destroy
    respond_to do |format|
      format.html { redirect_to pro_promotion_codes_path }
    end
  end

end
