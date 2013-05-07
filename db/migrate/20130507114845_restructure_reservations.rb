class RestructureReservations < ActiveRecord::Migration
  def up
    remove_column :reservations, :course_id
    remove_column :reservations, :planning_id
    remove_column :reservations, :price_id
    remove_column :reservations, :book_ticket_id
    remove_column :reservations, :name
    remove_column :reservations, :email
    remove_column :reservations, :name_on_card
    remove_column :reservations, :billing_address_first_line
    remove_column :reservations, :billing_address_second_line
    remove_column :reservations, :city_name
    remove_column :reservations, :zip_code
    remove_column :reservations, :phone
    remove_column :reservations, :start_date
    remove_column :reservations, :nb_participants

    change_table :reservations do |t|
      t.integer    :user_id
      t.references :reservable, :polymorphic => true
    end
  end

  def down
  end
end
