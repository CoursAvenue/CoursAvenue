class RenameBlogImagesToAdminImages < ActiveRecord::Migration
  def change
    rename_table :blog_images, :admin_images
  end
end
