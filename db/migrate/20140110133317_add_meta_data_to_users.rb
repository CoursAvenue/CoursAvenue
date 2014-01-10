class AddMetaDataToUsers < ActiveRecord::Migration
  def change
    add_column :users, :meta_data, :hstore
  end
end
