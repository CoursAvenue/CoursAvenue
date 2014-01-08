class AddPlanningsCountToStructure < ActiveRecord::Migration
  def change
    add_column :structures, :plannings_count, :integer

    bar = ProgressBar.new Structure.count
    Structure.find_each do |structure|
      bar.increment!
      structure.update_meta_datas
    end
  end
end
