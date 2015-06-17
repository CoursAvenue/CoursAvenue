# encoding: utf-8
class Pro::Blog::ArticlesController < Pro::ProController

  before_action :load_categories
  before_action :load_article, only: [:show]

  layout 'pro_blog'

  def index
    @articles   = ::Blog::Article::ProArticle.ordered_by_publish_date.published.page(params[:page] || 1).per(5)
  end

  def show
    @article_decorator = BlogArticleDecorator.new @article
    @category          = @article.category
  end

  def category_index
    @category = ::Blog::Category::ProCategory.find params[:category_id]
    @articles = @category.articles.ordered_by_publish_date.published.page(params[:page] || 1).per(5)
  end

  private

  def load_categories
    @categories = ::Blog::Category::ProCategory.at_depth(0).order('position ASC NULLS LAST').all
  end

  def load_article
    @article = ::Blog::Article.friendly.find(params[:id])
    if @article.type == 'Blog::Article::UserArticle'
      redirect_to blog_article_path(@article, subdomain: 'www'), status: 301
    elsif @article.slug != params[:id]
      redirect_to pro_blog_article_path(@article.slug), status: 301
    end
  end
end
