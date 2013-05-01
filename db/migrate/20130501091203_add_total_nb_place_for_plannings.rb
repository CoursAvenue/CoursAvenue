class AddTotalNbPlaceForPlannings < ActiveRecord::Migration
  def change
    add_column :plannings, :total_nb_place, :integer
  end
end
