class AddPlaceIdToPlannings < ActiveRecord::Migration
  def change
    add_column :plannings, :place_id, :integer
  end
end
