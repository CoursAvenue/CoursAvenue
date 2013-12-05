class CreateSearchTermLogs < ActiveRecord::Migration
  def change
    create_table :search_term_logs do |t|
      t.string :name
      t.integer :count, default: 0
      t.timestamps
    end
  end
end
