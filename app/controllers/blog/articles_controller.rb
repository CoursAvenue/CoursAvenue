# encoding: utf-8
class Blog::ArticlesController < ApplicationController

  layout 'blog'

  def index
    @articles = Blog::Article.published.page(params[:page] || 1).per(5)
  end

  def show
    @article = Blog::Article.find params[:id]
  end
end
