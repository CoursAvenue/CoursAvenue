class AddNoFacebookAndNoWebsiteField < ActiveRecord::Migration
  def change
    add_column :structures, :no_facebook, :boolean
    add_column :structures, :no_website , :boolean
  end
end
