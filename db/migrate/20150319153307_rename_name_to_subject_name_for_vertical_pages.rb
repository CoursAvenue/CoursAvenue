class RenameNameToSubjectNameForVerticalPages < ActiveRecord::Migration
  def change
    rename_column :vertical_pages, :name, :subject_name
  end
end
