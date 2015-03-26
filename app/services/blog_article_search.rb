class BlogArticleSearch

  # params: params
  #     name:          fulltext
  #     subject_id:    slug of a subject
  #     audience_ids:  [1, 2, 3]
  #     level_ids:     [1, 2, 3]
  def self.search params
    params[:sort] ||= 'rating_desc'

    @search = Sunspot.search(Blog::Article) do
      fulltext params[:name]           if params[:name].present?
      paginate page: (params[:page] || 1), per_page: (params[:per_page] || 15)

      order_by :page_views, :desc
      order_by :created_at, :desc
      with(:subject_slugs).any_of params[:subject_slugs]
    end

    @search
  end
end
