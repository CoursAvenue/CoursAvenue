class AddShowTrainingsFirstToStructures < ActiveRecord::Migration
  def change
    add_column :structures, :show_trainings_first, :boolean, default: true
    Structure.update_all(show_trainings_first: true)
  end
end
