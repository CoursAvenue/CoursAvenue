class AddCloudinaryBackupToUsers < ActiveRecord::Migration
  def change
    add_column :users, :c_image, :string
  end
end
