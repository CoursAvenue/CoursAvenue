class RenameObjectToEmailObjectInNewsletter < ActiveRecord::Migration
  def change
    rename_column :newsletters, :object, :email_object
  end
end
