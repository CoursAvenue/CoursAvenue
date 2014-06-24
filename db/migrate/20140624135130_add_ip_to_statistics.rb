class AddIpToStatistics < ActiveRecord::Migration
  def change
    add_column :statistics, :ip_address, :string
  end
end
