class AddMetaDataToStructures < ActiveRecord::Migration
  def up
    remove_column :structures, :audience_ids
    remove_column :structures, :gives_group_courses
    remove_column :structures, :gives_individual_courses
    remove_column :structures, :plannings_count
    remove_column :structures, :has_promotion
    remove_column :structures, :has_free_trial_course
    remove_column :structures, :course_names
    remove_column :structures, :last_comment_title

    add_column :structures, :meta_data, :hstore

    bar = ProgressBar.new Structure.count
    Structure.find_each do |structure|
      bar.increment!
      structure.send(:update_meta_datas)
    end
  end
  def down
    remove_column :structures, :meta_data

    add_column :structures, :audience_ids, :string
    add_column :structures, :gives_group_courses, :string
    add_column :structures, :gives_individual_courses, :string
    add_column :structures, :plannings_count, :string
    add_column :structures, :has_promotion, :string
    add_column :structures, :has_free_trial_course, :string
    add_column :structures, :course_names, :string
    add_column :structures, :last_comment_title, :string
  end
end
