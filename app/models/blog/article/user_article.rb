class Blog::Article::UserArticle < Blog::Article
  friendly_id :title, use: [:slugged, :finders]

  belongs_to :category, class_name: 'Blog::Category::UserCategory', foreign_key: :category_id

  # Return similar articles
  def similar_articles(limit = 3)
    articles = []
    if self.category
      articles = self.category.articles.reject { |article| article.id == self.id }.take(limit)
    end
    articles += Blog::Article::UserArticle.published.tagged_with(self.tags).take(limit - articles.length)
    articles += Blog::Article::UserArticle.order('RANDOM()').take(limit - articles.length)
    articles.reject { |article| article.id == self.id }.uniq.take(limit)
  end
end
