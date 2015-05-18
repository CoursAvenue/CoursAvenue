class Blog::Category::UserCategory < Blog::Category
  friendly_id :name, use: [:slugged, :finders, :history]
end
