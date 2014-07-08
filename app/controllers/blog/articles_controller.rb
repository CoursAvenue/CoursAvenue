# encoding: utf-8
class Blog::ArticlesController < ApplicationController

  layout 'blog'

  def index
    @articles = Blog::Article.published.page(params[:page] || 1).per(5)
  end

  def tags
    @articles = Blog::Article.published.tagged_with(params[:tag]).published.page(params[:page] || 1).per(5)
  end

  def show
    @article = Blog::Article.find params[:id]
    redirect_to blog_articles_path if ! @article.published?
  end
end
