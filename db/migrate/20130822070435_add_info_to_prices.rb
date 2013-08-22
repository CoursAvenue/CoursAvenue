class AddInfoToPrices < ActiveRecord::Migration
  def change
    add_column :prices, :info, :string
    add_column :book_tickets, :info, :string
  end
end
