class AddingTypeToBlogArticlesAndCategories < ActiveRecord::Migration
  def change
    add_column :blog_articles, :type, :string
    add_column :blog_categories, :type, :string

    Blog::Article.update_all  type: 'Blog::Article::UserArticle'
    Blog::Category.update_all type: 'Blog::Article::UserCategory'
  end
end
