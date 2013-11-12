class StickerDemand < ActiveRecord::Base
  belongs_to :structure

  attr_accessible :round_number, :square_number, :address, :sent
  validate :at_least_one_sticker, on: :create

  private

  def at_least_one_sticker
    if self.round_number == 0 and self.square_number == 0
      self.errors[:base] << I18n.t('sticker_demands.errors.at_least_one_sticker')
    end
  end
end
