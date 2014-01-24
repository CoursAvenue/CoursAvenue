class AddDeletedAtToParticipations < ActiveRecord::Migration
  def change
    add_column :participations, :deleted_at, :time
  end
end
