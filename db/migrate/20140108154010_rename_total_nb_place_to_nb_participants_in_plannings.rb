class RenameTotalNbPlaceToNbParticipantsInPlannings < ActiveRecord::Migration
  def change
    rename_column :plannings, :total_nb_place, :nb_participants_max
  end
end
