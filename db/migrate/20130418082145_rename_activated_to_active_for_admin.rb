class RenameActivatedToActiveForAdmin < ActiveRecord::Migration
  def change
    rename_column :admins, :activated, :active
  end
end
