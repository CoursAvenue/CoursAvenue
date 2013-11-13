class AddAddressToStickerDemand < ActiveRecord::Migration
  def change
    add_column :sticker_demands, :address, :text
  end
end
