class AddRatingToStructure < ActiveRecord::Migration
  def change
    add_column :structures, :rating, :decimal
  end
end
