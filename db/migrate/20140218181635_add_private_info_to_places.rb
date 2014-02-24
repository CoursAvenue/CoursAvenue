class AddPrivateInfoToPlaces < ActiveRecord::Migration
  def change
    add_column :places, :private_info, :text
  end
end
