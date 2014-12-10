class RenameLogoFromStructures < ActiveRecord::Migration
  def change
    rename_column :structures, :logo_file_name, :old_logo_file_name
    rename_column :structures, :logo_file_size, :old_logo_file_size
    rename_column :structures, :logo_content_type, :old_logo_content_type
    rename_column :structures, :logo_updated_at, :old_logo_updated_at

    rename_column :structures, :sleeping_logo_file_name, :old_sleeping_logo_file_name
    rename_column :structures, :sleeping_logo_file_size, :old_sleeping_logo_file_size
    rename_column :structures, :sleeping_logo_content_type, :old_sleeping_logo_content_type
    rename_column :structures, :sleeping_logo_updated_at, :old_sleeping_logo_updated_at

    rename_column :structures, :c_logo, :logo
    rename_column :structures, :c_sleeping_logo, :sleeping_logo
  end
end
