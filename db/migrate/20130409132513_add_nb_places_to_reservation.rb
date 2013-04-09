class AddNbPlacesToReservation < ActiveRecord::Migration
  def change
    add_column :reservations, :nb_participants, :integer
  end
end
