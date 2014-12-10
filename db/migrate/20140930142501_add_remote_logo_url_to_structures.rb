class AddRemoteLogoUrlToStructures < ActiveRecord::Migration
  def change
    add_column :structures, :remote_logo_url, :string
  end
end
