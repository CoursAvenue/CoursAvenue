class AddBoxTopAndBoxBottomToArticles < ActiveRecord::Migration
  def change
    add_column :blog_articles, :box_top, :text
    add_column :blog_articles, :box_bottom, :text
  end
end
