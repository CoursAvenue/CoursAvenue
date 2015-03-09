class AddDefaultToOnDropbox < ActiveRecord::Migration
  def up
    change_column_default :orders, :on_dropbox, false
  end

  def down
    change_column_default :orders, :on_dropbox, nil
  end
end
