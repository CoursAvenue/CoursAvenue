class AddSponsorshipIdToUsers < ActiveRecord::Migration
  def change
    add_column :users, :sponsorship_id, :integer
  end
end
