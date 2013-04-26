class AddSubjectStringToCourseAndPlaces < ActiveRecord::Migration
  def up
    add_column :courses,    :subjects_string, :text
    add_column :courses,    :parent_subjects_string, :text
    add_column :places,     :subjects_string, :text
    add_column :places,     :parent_subjects_string, :text
    add_column :structures, :subjects_string, :text
    add_column :structures, :parent_subjects_string, :text

    [Course, Place, Structure].each do |class_name|
      class_name.all.each do |instance_object|
        instance_object.update_subjects_string
        instance_object.update_parent_subjects_string
      end
    end
  end

  def down
    remove_column :courses,    :subjects_string
    remove_column :courses,    :parent_subjects_string
    remove_column :places,     :subjects_string
    remove_column :places,     :parent_subjects_string
    remove_column :structures, :subjects_string
    remove_column :structures, :parent_subjects_string
  end
end
