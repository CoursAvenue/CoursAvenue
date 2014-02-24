class AddForAttributeToParticipations < ActiveRecord::Migration
  def change
    add_column :participations, :participation_for, :string
  end
end
