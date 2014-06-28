# encoding: utf-8
class Blog::ArticlesController < ApplicationController
  before_action :authenticate_pro_super_admin!, except: [:index, :show]

  def index
    @articles = Blog::Article.all
  end

  def new
    @article = Blog::Article.new
  end

  def edit
    @article = Blog::Article.find params[:id]
  end

  def show
    @article = Blog::Article.find params[:id]
  end

  def create
    @article = Blog::Article.new params[:blog_article]
    @article.save
    respond_to do |format|
      format.html { redirect_to blog_articles_path }
    end
  end

  def update
    @article = Blog::Article.find params[:id]
    @article.update_attributes params[:blog_article]
    respond_to do |format|
      format.html { redirect_to blog_articles_path }
    end
  end
end
