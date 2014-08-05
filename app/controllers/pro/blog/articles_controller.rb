# encoding: utf-8
class Pro::Blog::ArticlesController < Pro::ProController
  before_action :authenticate_pro_super_admin!

  def index
    @articles = ::Blog::Article.all
  end

  def new
    @article = ::Blog::Article.new
  end

  def edit
    @article = ::Blog::Article.find params[:id]
  end

  def show
    @article = ::Blog::Article.find params[:id]
  end

  def create
    @article = ::Blog::Article.new params[:blog_article]
    respond_to do |format|
      if @article.save
        format.html { redirect_to pro_blog_articles_path }
      else
        format.html { render action: :new }
      end
    end
  end

  def update
    @article = ::Blog::Article.find params[:id]
    respond_to do |format|
      if @article.update_attributes params[:blog_article]
        format.html { redirect_to pro_blog_articles_path }
      else
        format.html { render action: :edit }
      end
    end
  end

  def destroy
    @article = ::Blog::Article.find params[:id]
    @article.destroy
    respond_to do |format|
      format.html { redirect_to pro_blog_articles_path, notice: "Supprimé !" }
    end
  end
end
