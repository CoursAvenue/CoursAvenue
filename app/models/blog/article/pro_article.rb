class Blog::Article::ProArticle < Blog::Article
  friendly_id :title_with_date, use: [:slugged, :finders]

  belongs_to :category, class_name: 'Blog::Category::ProCategory', foreign_key: :category_id

  def pro_article?
    true
  end
end
