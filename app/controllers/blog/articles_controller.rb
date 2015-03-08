# encoding: utf-8
class Blog::ArticlesController < ApplicationController

  layout 'blog'

  def index
    @articles = Blog::Article.published.page(params[:page] || 1).per(5)
  end

  def tags
    @articles = Blog::Article.published.tagged_with(params[:tag]).page(params[:page] || 1).per(5)
  end

  def show
    @article = Blog::Article.find params[:id]
    if !current_pro_admin and !current_pro_admin.super_admin? and !@article.published?
      redirect_to blog_articles_path
    end
  end

  def category_show
    @category = Blog::Category.find params[:category_id]
    @article  = Blog::Article.find params[:id]
    if !current_pro_admin and !current_pro_admin.super_admin? and !@article.published?
      redirect_to blog_articles_path
    end
    render action: :show
  end

  def category_index
    @category = Blog::Category.find params[:category_id]
    @articles = @category.articles.page(params[:page] || 1).per(5)
  end
end
