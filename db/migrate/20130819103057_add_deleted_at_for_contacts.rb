class AddDeletedAtForContacts < ActiveRecord::Migration
  def change
    add_column :contacts, :deleted_at, :time
  end
end
