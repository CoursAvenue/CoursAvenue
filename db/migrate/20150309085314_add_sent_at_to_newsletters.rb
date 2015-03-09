class AddSentAtToNewsletters < ActiveRecord::Migration
  def change
    add_column :newsletters, :sent_at, :datetime
  end
end
