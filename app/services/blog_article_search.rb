class BlogArticleSearch < BaseSearch
  # ActiveRecord doesn't build the actual query until we tried to use the results, so we can
  # manually create the query and simply return it.
  #
  # <http://stackoverflow.com/questions/6084743/rails-activerecord-building-queries-dynamically>
  def self.search(params)
    article_cache_key = Blog::Article.with_deleted.maximum(:updated_at).to_i
    Rails.cache.fetch("BlogArticleSearch/#{ BlogArticleSearch.params_to_cache_key(params) }/#{ article_cache_key }") do
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

      if params[:subject_slugs].present?
        articles = articles.includes(:subjects).joins(:subjects).
          where('blog_articles_subjects.subject_id = subjects.id AND subjects.slug in ?', params[:subject_slugs])
      end

      # Finally, we paginate the results.
      articles.page(page).per(per_page)
    end
  end

  # TODO: Make sure the attributes are always in the same order and return the same string.
  def self.params_to_cache_key(params)
    params.to_param
  end
end
