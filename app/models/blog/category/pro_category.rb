class Blog::Category::ProCategory < Blog::Category
  friendly_id :name, use: [:slugged, :finders]

  def pro_category?
    true
  end

end
