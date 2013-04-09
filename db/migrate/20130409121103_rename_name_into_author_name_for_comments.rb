class RenameNameIntoAuthorNameForComments < ActiveRecord::Migration
  def change
    rename_column :comments, :name, :author_name
  end
end
