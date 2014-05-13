class AddPromoAmountType < ActiveRecord::Migration
  def change
    add_column :prices, :promo_amount_type, :string
  end
end
