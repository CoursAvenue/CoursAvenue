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
      with(:subject_slugs).any_of               params[:subject_slugs] if params[:subject_slugs].present?

      with :type, params[:type] if params[:type].present?
      with :published, true

      order_by :page_views, :desc
      order_by :created_at, :desc
    end

    @search
  end

  # ActiveRecord doesn't build the actual query until we tried to use the results, so we can
  # manually create the query and simply return it.
  #
  # <http://stackoverflow.com/questions/6084743/rails-activerecord-building-queries-dynamically>
  def self.search_activerecord(params)
    page     = params[:page] || 1
    per_page = params[:per_page] || 15

    # Default query, the one that is always the same.
    articles = Blog::Article.where(published: true).
      order(page_views: :desc, created_at: :desc)

    # Now we actually build the query with the params we have.
    if params[:name].present?
      articles = articles.basic_search(params[:name])
    end

    if params[:type].present?
      type = (params[:type] == 'user' ? 'Blog::Article::UserArticle' : 'Blog::Article::ProArticle')
      articles = articles.where(type: type)
    end

    # http://til.hashrocket.com/posts/53fa4e867f-activerecord-subselects
    if params[:subject_slugs].present?
      articles = articles.includes(:subjects).joins(:subjects).
        where('blog_articles_subjects.subject_id = subjects.id AND subjects.slug in ?', params[:subject_slugs])
    end

    # Finally, we add the pagination
    articles.page(page).per(per_page)
  end
end
