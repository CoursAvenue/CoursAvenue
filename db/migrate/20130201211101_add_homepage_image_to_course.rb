class AddHomepageImageToCourse < ActiveRecord::Migration
  def change
    add_attachment :courses, :homepage_image
    add_attachment :courses, :image
  end
end
