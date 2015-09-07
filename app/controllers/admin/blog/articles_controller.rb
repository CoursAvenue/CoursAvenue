# encoding: utf-8
class Admin::Blog::ArticlesController < Admin::AdminController

  def index
    get_categories
    @articles   = blog_article_class.order('published_at DESC').all
  end

  def new
    get_categories
    @article = blog_article_class.new
  end

  def edit
    @article = ::Blog::Article.friendly.find params[:id]
    @medias  = @article.medias.order('caption ASC')
    get_categories
  end

  def show
    @article = ::Blog::Article.friendly.find params[:id]
  end

  def create
    @article = ::Blog::Article.new params[:blog_article]
    respond_to do |format|
      if @article.save
        format.html { redirect_to admin_blog_articles_path(type: (@article.pro_article? ? 'pro' : 'user')) }
      else
        format.html { render action: :new }
      end
    end
  end

  def update
    @article = ::Blog::Article.friendly.find params[:id]
    respond_to do |format|
      if @article.update_attributes params[:blog_article]
        format.html { redirect_to admin_blog_articles_path(type: (@article.pro_article? ? 'pro' : 'user')) }
      else
        format.html { render action: :edit }
      end
    end
  end

  def destroy
    @article = ::Blog::Article.friendly.find params[:id]
    @article.destroy
    respond_to do |format|
      format.html { redirect_to admin_blog_articles_path(type: (@article.pro_article? ? 'pro' : 'user')), notice: "Supprimé !" }
    end
  end

  private

  def blog_article_class
    (params[:type] == 'pro' ?  ::Blog::Article::ProArticle : ::Blog::Article::UserArticle)
  end

  def blog_category_class
    if @article
      (@article.pro_article? ?  ::Blog::Category::ProCategory : ::Blog::Category::UserCategory)
    else
      (params[:type] == 'pro' ?  ::Blog::Category::ProCategory : ::Blog::Category::UserCategory)
    end
  end

  def get_categories
    @categories = blog_category_class.all
  end
end
