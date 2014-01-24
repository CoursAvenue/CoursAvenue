class AddInfoToOpenCourses < ActiveRecord::Migration
  def change
    add_column :courses, :event_type            , :string
    add_column :courses, :event_type_description, :string
    add_column :courses, :price                 , :float
  end
end
