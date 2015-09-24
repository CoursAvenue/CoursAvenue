class AddDeletedAtToUserProfile < ActiveRecord::Migration
  def change
    add_column :user_profiles, :deleted_at, :datetime
  end
end
