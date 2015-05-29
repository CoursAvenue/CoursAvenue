class AddChargedAtToSubscriptions < ActiveRecord::Migration
  def change
    add_column :subscriptions, :charged_at, :datetime
  end
end
