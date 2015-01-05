class AddOnDropboxToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :on_dropbox, :boolean
  end
end
