class AddDeletedAtToStatistic < ActiveRecord::Migration
  def change
    add_column :statistics, :deleted_at, :time
  end
end
