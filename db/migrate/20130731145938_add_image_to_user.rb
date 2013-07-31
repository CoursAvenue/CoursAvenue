class AddImageToUser < ActiveRecord::Migration
  def change
    rename_column :users, :image, :fb_avatar
    add_attachment :users, :avatar
  end
end
