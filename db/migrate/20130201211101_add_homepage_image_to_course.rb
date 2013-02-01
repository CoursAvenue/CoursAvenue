class AddHomepageImageToCourse < ActiveRecord::Migration
  def change
    add_attachment :courses, :homepage_image
  end
end
