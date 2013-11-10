class CreateStickerDemands < ActiveRecord::Migration
  def change
    create_table :sticker_demands do |t|
      t.integer :round_number
      t.integer :square_number

      t.boolean :sent, default: false
      t.time :sent_at

      t.references :structure
      t.timestamps
    end
  end
end
