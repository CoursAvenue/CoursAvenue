class RemoveMinAndMaxPriceIdFromStructures < ActiveRecord::Migration

  def up
    remove_column :structures, :min_price_id
    remove_column :structures, :max_price_id
    bar = ProgressBar.new Structure.count
    Structure.find_each do |structure|
      bar.increment!
      structure.send(:set_min_and_max_price)
      structure.save
    end
  end

  def down
    add_column :structures, :min_price_id, :integer
    add_column :structures, :max_price_id, :integer
  end
end
