class RemoveOnboardedFromAdmin < ActiveRecord::Migration
  def change
    remove_column :admins, :onboarded
  end
end
