class AddDefaultToStateColumn < ActiveRecord::Migration
  def change
    change_column :sponsorships, :state, :string, default: "pending"
  end
end
