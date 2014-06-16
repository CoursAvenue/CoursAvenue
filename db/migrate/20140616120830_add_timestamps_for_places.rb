class AddTimestampsForPlaces < ActiveRecord::Migration
  def change
    add_column(:places, :created_at, :datetime)
    add_column(:places, :updated_at, :datetime)
  end
end
