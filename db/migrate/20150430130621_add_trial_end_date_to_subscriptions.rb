class AddTrialEndDateToSubscriptions < ActiveRecord::Migration
  def change
    add_column :subscriptions, :trial_end, :datetime
  end
end
