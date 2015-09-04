class AddCloudinaryHeaderImageToEmailings < ActiveRecord::Migration
  def change
    add_column :emailings, :header_image, :string
    rename_column :emailings, :header_image_file_name, :old_header_image_file_name
    rename_column :emailings, :header_image_content_type, :old_header_image_content_type
    rename_column :emailings, :header_image_file_size, :old_header_image_file_size
    rename_column :emailings, :header_image_updated_at, :old_header_image_updated_at

    if Rails.env.production?
      bar = ProgressBar.new(Emailing.where.not(old_header_image_file_name: nil).count)
      Emailing.where.not(old_header_image_file_name: nil).find_each do |emailing|
        bar.increment!
        next if emailing.old_header_image.blank?
        emailing.remote_header_image_url = emailing.old_header_image.url
        emailing.save
      end
    end
  end
end
