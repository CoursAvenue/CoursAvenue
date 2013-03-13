class AddRoomIdToPlanning < ActiveRecord::Migration
  def change
    add_column :plannings, :room_id, :integer
  end
end
