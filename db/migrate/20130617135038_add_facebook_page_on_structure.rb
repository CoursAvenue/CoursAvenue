class AddFacebookPageOnStructure < ActiveRecord::Migration
  def change
    add_column :structures, :facebook_url, :string
  end
end
