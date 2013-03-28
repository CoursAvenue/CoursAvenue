class AddContactNameToRentingRooms < ActiveRecord::Migration
  def change
    add_column :renting_rooms, :contact_name, :string
    add_column :renting_rooms, :address, :string

    change_column :renting_rooms, :contact_phone, :string
    change_column :renting_rooms, :contact_mail, :string

    rename_column :renting_rooms, :contact_mail, :contact_email
  end
end
