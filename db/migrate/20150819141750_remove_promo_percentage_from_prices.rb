class RemovePromoPercentageFromPrices < ActiveRecord::Migration
  def up
    remove_column :prices, :promo_percentage
  end

  def down
    add_column :prices, :promo_percentage, :decimal
  end
end
