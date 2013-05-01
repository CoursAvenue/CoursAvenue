class AddPromoPriceToPrices < ActiveRecord::Migration
  def change
    add_column    :prices,       :promo_amount, :decimal
    add_column    :book_tickets, :promo_amount, :decimal

    rename_column :book_tickets, :price, :amount
  end
end
