class AddDiscoveryPassPolicyToStructures < ActiveRecord::Migration
  def change
    add_column :structures, :discovery_pass_policy, :string
  end
end
