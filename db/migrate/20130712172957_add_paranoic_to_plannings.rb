class AddParanoicToPlannings < ActiveRecord::Migration
  def change
    add_column :plannings, :deleted_at, :time
  end
end
