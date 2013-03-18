class ChangeValidityIntoInteger < ActiveRecord::Migration
  def up
    BookTicket.connection.execute('ALTER TABLE book_tickets ALTER validity type decimal using validity::decimal;')
  end

  def down
    change_column :book_tickets, :validity, :string
  end
end
