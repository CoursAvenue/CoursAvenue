class AddParanoicAdmin < ActiveRecord::Migration
  def change
    add_column :admins, :deleted_at, :time
  end
end
