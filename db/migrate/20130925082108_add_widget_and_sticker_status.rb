class AddWidgetAndStickerStatus < ActiveRecord::Migration
  def change
    add_column :structures, :widget_status , :string
    add_column :structures, :sticker_status, :string
  end
end
