class DropTableSearchTermLogs < ActiveRecord::Migration
  def change
    drop_table :search_term_logs
  end
end
