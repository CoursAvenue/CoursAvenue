class RenameLogoToStructures < ActiveRecord::Migration
  def change
    rename_column :structures, :logo_file_name, :logo
  end
end
