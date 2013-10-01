class ChangeTypeOfFacebookUrlOnStructures < ActiveRecord::Migration
  def up
    update_column :structures, :facebook_url, :text
  end

  def down
    update_column :structures, :facebook_url, :string
  end
end
