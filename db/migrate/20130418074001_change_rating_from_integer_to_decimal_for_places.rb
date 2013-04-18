class ChangeRatingFromIntegerToDecimalForPlaces < ActiveRecord::Migration
  def up
    change_column :places, :rating, :decimal
  end

  def down
    change_column :places, :rating, :decimal
  end
end
