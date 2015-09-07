class AddImageToTeachers < ActiveRecord::Migration
  def change
    add_column :teachers, :image, :string
    rename_column :teachers, :image_file_name, :old_image_file_name
    rename_column :teachers, :image_content_type, :old_image_content_type
    rename_column :teachers, :image_file_size, :old_image_file_size
    rename_column :teachers, :image_updated_at, :old_image_updated_at

    # if Rails.env.production?
    #   bar = ProgressBar.new(Teacher.where.not(old_image_file_name: nil).count)
    #   Teacher.where.not(old_image_file_name: nil).find_each do |teacher|
    #     bar.increment!
    #     next if teacher.old_image.blank?
    #     teacher.remote_image_url = teacher.old_image.url
    #     teacher.save
    #   end
    # end
  end
end
