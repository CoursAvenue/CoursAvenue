class CreateBookTickets < ActiveRecord::Migration
  def change
    create_table :book_tickets do |t|
      t.integer :number
      t.decimal :price
      t.string :validity
      t.string :validity

      t.references :course_group

      t.timestamps
    end
  end
end
