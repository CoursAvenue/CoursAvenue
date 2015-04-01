# encoding: utf-8
class Blog::ArticlesController < ApplicationController

  layout 'blog'

  def index
    @articles   = Blog::Article::UserArticle.ordered_by_publish_date.published.page(params[:page] || 1).per(8)
  end

  def tags
    @tag = params[:tag]
    @articles = Blog::Article::UserArticle.ordered_by_publish_date.published.tagged_with(params[:tag]).page(params[:page] || 1).per(5)
  end

  def show
    @article = Blog::Article::UserArticle.where(slug: params[:id]).first
    @article = Blog::Article::UserArticle.find(params[:id])
    redirect_to(blog_articles_path, status: 301) if @article.nil?
    @article.increment_page_views! if @article
    @article_decorator = BlogArticleDecorator.new(@article) if @article
    unless current_pro_admin and current_pro_admin.super_admin?
      redirect_to blog_articles_path if ! @article.published?
    end
  end

  def category_index
    @category = Blog::Category::UserCategory.find params[:category_id]
    @articles = @category.articles.page(params[:page] || 1).per(5)
  end
end
