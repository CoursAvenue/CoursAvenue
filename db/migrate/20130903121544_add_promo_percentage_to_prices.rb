class AddPromoPercentageToPrices < ActiveRecord::Migration
  def change
    add_column :prices, :promo_percentage, :decimal
  end
end
