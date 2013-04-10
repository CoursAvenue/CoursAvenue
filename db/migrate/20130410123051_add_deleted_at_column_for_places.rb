class AddDeletedAtColumnForPlaces < ActiveRecord::Migration
  def change
    add_column :places, :deleted_at, :time
  end
end
