class Blog::Category::ProCategory < Blog::Category
  friendly_id :name, use: [:slugged, :finders, :history]

  def articles
    if self.root?
      Blog::Article::ProArticle.where(:category_id => [self.id] + self.children.map(&:id))
    else
      Blog::Article::ProArticle.where(:category_id => self.path_ids)
    end
  end

  def pro_category?
    true
  end

end
