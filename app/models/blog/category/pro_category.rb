class Blog::Category::ProCategory < Blog::Category
  friendly_id :name, use: [:slugged, :finders]

  def articles
    Blog::Article::ProArticle.where(:category_id => self.path_ids)
  end

  def pro_category?
    true
  end

end
