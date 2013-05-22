class UpdateLevelOrders < ActiveRecord::Migration
  def up
    confirmed = Level.where(name: 'level.confirmed').first
    confirmed.update_column(:order, 4)
  end

  def down
  end
end
