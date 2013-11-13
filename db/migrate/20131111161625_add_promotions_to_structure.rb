class AddPromotionsToStructure < ActiveRecord::Migration
  def change
    add_column :structures, :has_promotion, :boolean, default: false
    bar = ProgressBar.new Structure.count
    Structure.find_each do |structure|
      bar.increment!
      structure.update_synced_attributes
    end
  end
end
