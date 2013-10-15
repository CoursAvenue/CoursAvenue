class RemoveRentingRooms < ActiveRecord::Migration
  def change
    drop_table :renting_rooms
  end
end
