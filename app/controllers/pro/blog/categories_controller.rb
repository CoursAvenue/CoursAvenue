# encoding: utf-8
class Pro::Blog::CategoriesController < Pro::ProController
  before_action :authenticate_pro_super_admin!

  def edit
    @category = ::Blog::Category.find params[:id]
    render partial: 'form', layout: false
  end

  def update
    @category = ::Blog::Category.find params[:id]
    @category.update_attributes params[:blog_category]
    respond_to do |format|
      format.html { redirect_to pro_blog_articles_path }
    end
  end

  def destroy
    @category = ::Blog::Category.find params[:id]
    @category.destroy
    respond_to do |format|
      format.html { redirect_to pro_blog_articles_path, notice: "Supprimé !" }
    end
  end

end
