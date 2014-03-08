class ChangeFingerprintTypeInVisitors < ActiveRecord::Migration
  def change
    change_column :visitors, :fingerprint, :string
  end
end
