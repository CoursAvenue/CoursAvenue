class Blog::Article::UserArticle < Blog::Article
  friendly_id :title_with_date, use: [:slugged, :finders]

  belongs_to :category, class_name: 'Blog::Category::UserCategory', foreign_key: :category_id
end
