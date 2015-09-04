# encoding: utf-8
class Admin::Blog::CategoriesController < Admin::AdminController

  def new
    @category = blog_category_class.new
  end

  def create
    params[:blog_category].delete(:ancestry) if params[:blog_category][:ancestry].blank?
    @category = ::Blog::Category.create params[:blog_category]
    respond_to do |format|
      format.html { redirect_to admin_blog_articles_path(type: (@category.pro_category? ? 'pro' : 'user')) }
    end
  end

  def edit
    @category = ::Blog::Category.find params[:id]
  end

  def update
    @category = ::Blog::Category.find params[:id]
    params[:blog_category].delete(:ancestry) if params[:blog_category][:ancestry].blank?
    @category.update_attributes params[:blog_category]
    respond_to do |format|
      format.html { redirect_to admin_blog_articles_path(type: (@category.pro_category? ? 'pro' : 'user')) }
    end
  end

  def destroy
    @category = ::Blog::Category.find params[:id]
    @category.destroy
    respond_to do |format|
      format.html { redirect_to admin_blog_articles_path(type: (@category.pro_category? ? 'pro' : 'user')), notice: "Supprimé !" }
    end
  end

  private

  def blog_category_class
    (params[:type] == 'pro' ?  ::Blog::Category::ProCategory : ::Blog::Category::UserCategory)
  end
end
