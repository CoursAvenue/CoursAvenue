class AddRoomDependencyToCourse < ActiveRecord::Migration
  def change
    add_column :courses, :room_id, :integer
  end
end
