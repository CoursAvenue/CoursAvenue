class RenameTrialEndByTrialEndsAtToSubscriptions < ActiveRecord::Migration
  def change
    rename_column :subscriptions, :trial_end, :trial_ends_at
  end
end
