class AddStructureIdToPlannings < ActiveRecord::Migration
  def up
    add_column :plannings, :structure_id, :integer

    bar = ProgressBar.new Planning.count
    Planning.find_each do |planning|
      bar.increment!
      if planning.course
        planning.update_column(:structure_id, planning.course.structure_id)
      else
        planning.destroy
      end
    end
  end

  def down
    remove_column :plannings, :structure_id, :integer
  end
end
