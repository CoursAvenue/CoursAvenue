# encoding: utf-8
class Blog::ArticlesController < ApplicationController

  layout 'blog'

  before_action :load_article, only: [:show]

  def index
    @articles = Blog::Article::UserArticle.ordered_by_publish_date.published.
      page(params[:page] || 1).per(8)
  end

  def tags
    @tag = params[:tag]
    @articles = Blog::Article::UserArticle.ordered_by_publish_date.published.
      tagged_with(params[:tag]).page(params[:page] || 1).per(5)
  end

  def show
    @article.increment_page_views!
    @article_decorator = BlogArticleDecorator.new(@article)
    unless current_pro_admin and current_pro_admin.super_admin?
      redirect_to blog_articles_path if ! @article.published?
    end
  end

  def category_index
    @category = Blog::Category::UserCategory.friendly.find params[:category_id]
    if @category.slug != params[:category_id]
      redirect_to category_blog_articles_path(category_id: @category.slug), status: 301
      return
    end
    @articles = @category.articles.ordered_by_publish_date.page(params[:page] || 1).per(5)
  end

  private

  def load_article
    # Add 301 redirection for old links that were pointing to pro articles
    if Blog::Article::ProArticle.where(slug: params[:id]).any?
      redirect_to pro_blog_article_url(params[:id], subdomain: 'pro'), status: 301
      return
    end
    @article = Blog::Article::UserArticle.friendly.find(params[:id])
    if @article.slug != params[:id]
      redirect_to blog_article_path(@article.slug), status: 301
    end
  end
end
