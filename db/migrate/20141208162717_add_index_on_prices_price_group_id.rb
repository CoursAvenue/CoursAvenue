class AddIndexOnPricesPriceGroupId < ActiveRecord::Migration
  def change
    add_index :prices, :price_group_id
  end
end
