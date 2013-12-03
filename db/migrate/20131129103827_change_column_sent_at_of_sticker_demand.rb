class ChangeColumnSentAtOfStickerDemand < ActiveRecord::Migration
  def up
    remove_column :sticker_demands, :sent_at
    remove_column :sticker_demands, :sent
    add_column    :sticker_demands, :sent_at, :datetime
  end

  def down
    remove_column :sticker_demands, :sent_at
    add_column    :sticker_demands, :sent_at, :datetime
    add_column    :sticker_demands, :sent, :boolean
  end
end
