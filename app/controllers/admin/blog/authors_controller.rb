# encoding: utf-8
class Admin::Blog::AuthorsController < Admin::AdminController

  def new
    @author = ::Blog::Author.new
  end

  def create
    @author = ::Blog::Author.create params[:blog_author]
    respond_to do |format|
      format.html { redirect_to admin_blog_articles_path }
    end
  end

  def edit
    @author = ::Blog::Author.find params[:id]
  end

  def update
    @author = ::Blog::Author.find params[:id]
    @author.update_attributes params[:blog_author]
    respond_to do |format|
      format.html { redirect_to admin_blog_articles_path }
    end
  end

  def destroy
    @author = ::Blog::Author.find params[:id]
    @author.destroy
    respond_to do |format|
      format.html { redirect_to admin_blog_articles_path, notice: "Supprimé !" }
    end
  end
end
