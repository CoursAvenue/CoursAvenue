class ChangeMediaUrlToText < ActiveRecord::Migration
  def up
   change_column :medias, :url, :text
  end

  def down
   change_column :medias, :url, :string
  end
end
