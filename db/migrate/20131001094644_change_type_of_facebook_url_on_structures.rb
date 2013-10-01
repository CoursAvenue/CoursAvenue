class ChangeTypeOfFacebookUrlOnStructures < ActiveRecord::Migration
  def up
    change_column :structures, :facebook_url, :text
  end

  def down
    change_column :structures, :facebook_url, :string
  end
end
