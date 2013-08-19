class AddParanoicFieldToPrices < ActiveRecord::Migration
  def change
    add_column :prices,            :deleted_at, :time
    add_column :book_tickets,      :deleted_at, :time
    add_column :registration_fees, :deleted_at, :time
  end
end
