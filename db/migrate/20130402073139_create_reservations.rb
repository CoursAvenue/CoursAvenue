class CreateReservations < ActiveRecord::Migration
  def change
    create_table :reservations do |t|

      t.string :first_name
      t.string :last_name
      t.string :email

      # Payment information
      t.string :name_on_card
      t.string :billing_address_first_line
      t.string :billing_address_second_line
      t.string :city_name
      t.string :zip_code
      t.string :phone

      t.date :start_date

      t.references :course
      t.references :planning
      t.references :price
      t.timestamps
    end
  end
end
