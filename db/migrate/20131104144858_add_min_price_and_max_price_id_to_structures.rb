class AddMinPriceAndMaxPriceIdToStructures < ActiveRecord::Migration
  def change
    add_column :structures, :min_price_id, :integer
    add_column :structures, :max_price_id, :integer

    # Update all min and max prices
    Structure.all.map{|s| s.send :set_min_and_max_price}

  end
end
