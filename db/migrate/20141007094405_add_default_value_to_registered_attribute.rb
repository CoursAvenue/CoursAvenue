class AddDefaultValueToRegisteredAttribute < ActiveRecord::Migration
  def change
    change_column :sponsorships, :registered, :boolean, default: false
  end
end
