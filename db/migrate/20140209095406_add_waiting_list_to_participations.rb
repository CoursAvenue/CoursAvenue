class AddWaitingListToParticipations < ActiveRecord::Migration
  def change
    add_column :participations, :waiting_list, :boolean, default: false
  end
end
