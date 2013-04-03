class AddBookTicketIdToReservation < ActiveRecord::Migration
  def change
    add_column :reservations, :book_ticket_id, :integer
  end
end
