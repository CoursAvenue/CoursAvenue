class RemoveHomepageImage < ActiveRecord::Migration
  def up
    drop_attached_file :courses, :homepage_image
  end

  def down
  end
end
