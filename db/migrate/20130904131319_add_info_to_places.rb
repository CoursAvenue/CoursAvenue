class AddInfoToPlaces < ActiveRecord::Migration
  def change
    add_column :places, :info, :text
  end
end
