class RemoveUselessColumnInPrices < ActiveRecord::Migration
  def up
    remove_column :courses, :price_info
  end

  def down
  end
end
