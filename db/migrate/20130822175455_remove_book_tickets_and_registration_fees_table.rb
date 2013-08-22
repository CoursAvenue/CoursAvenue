class RemoveBookTicketsAndRegistrationFeesTable < ActiveRecord::Migration
  def up
    drop_table :registration_fees
    drop_table :book_tickets
  end

  def down
  end
end
