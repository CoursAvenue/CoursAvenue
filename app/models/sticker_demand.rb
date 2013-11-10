class StickerDemand < ActiveRecord::Base
  belongs_to :structure

  attr_accessible :round_number, :square_number, :sent

end
