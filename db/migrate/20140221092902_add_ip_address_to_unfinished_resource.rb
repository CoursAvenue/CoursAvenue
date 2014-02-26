class AddIpAddressToUnfinishedResource < ActiveRecord::Migration
  def change
    add_column :unfinished_resources, :ip_address, :string
  end
end
