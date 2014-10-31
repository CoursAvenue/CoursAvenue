class AddCertifiedToComments < ActiveRecord::Migration
  def change
    add_column :comments, :certified, :boolean
  end
end
