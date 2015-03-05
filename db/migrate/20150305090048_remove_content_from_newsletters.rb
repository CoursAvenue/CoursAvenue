class RemoveContentFromNewsletters < ActiveRecord::Migration
  def change
    remove_column :newsletters, :content, :text
  end
end
