# encoding: utf-8
class Pro::StickerDemandsController < Pro::ProController
  before_action :authenticate_pro_super_admin!

  def index
    @sticker_demands = StickerDemand.all
  end
end
