class AddPausedFlagToSubscriptions < ActiveRecord::Migration
  def change
    add_column :subscriptions, :paused, :boolean, default: false
  end
end
