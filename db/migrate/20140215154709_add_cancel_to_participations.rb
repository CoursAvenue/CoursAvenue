class AddCancelToParticipations < ActiveRecord::Migration
  def change
    add_column :participations, :canceled_at, :datetime
  end
end
