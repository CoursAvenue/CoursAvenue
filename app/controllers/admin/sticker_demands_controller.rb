# encoding: utf-8
class Admin::StickerDemandsController < Admin::AdminController
  def index
    @sticker_demands = StickerDemand.all
  end
end
