class AddMediaIdToCourses < ActiveRecord::Migration
  def change
    add_column :courses, :media_id, :integer
  end
end
