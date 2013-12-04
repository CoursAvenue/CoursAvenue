class RemoveCountFromSearchTermLog < ActiveRecord::Migration
  def up
    remove_column :search_term_logs, :count
    SearchTermLog.delete_all
  end

  def down
    add_column :search_term_logs, :count, :integer
  end
end
