class StickerDemand < ActiveRecord::Base
  belongs_to :structure

  attr_accessible :round_number, :square_number, :address, :sent
  validate :at_least_one_sticker, on: :create

  ######################################################################
  # Scopes                                                             #
  ######################################################################

  default_scope           { order('created_at DESC') }
  scope :sent,      -> { where.not(sent_at: nil) }
  scope :not_sent,  -> { where(sent_at: nil) }

  def sent?
    self.sent_at.present?
  end

  def send!
    self.update_column :sent_at, Time.now
  end

  private

  def at_least_one_sticker
    if self.round_number == 0 and self.square_number == 0
      self.errors[:base] << I18n.t('sticker_demands.errors.at_least_one_sticker')
    end
  end
end
