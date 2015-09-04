# encoding: utf-8
class Admin::PressArticlesController < Admin::AdminController

  def index
    @press_articles = PressArticle.all
  end

  def new
    @press_article = PressArticle.new
  end

  def edit
    @press_article = PressArticle.find params[:id]
  end

  def show
    @press_article = PressArticle.find params[:id]
  end

  def create
    @press_article = PressArticle.new params[:press_article]
    respond_to do |format|
      if @press_article.save
        format.html { redirect_to admin_press_articles_path }
      else
        format.html { render action: :new }
      end
    end
  end

  def update
    @press_article = PressArticle.find params[:id]
    respond_to do |format|
      if @press_article.update_attributes params[:press_article]
        format.html { redirect_to admin_press_articles_path }
      else
        format.html { render action: :edit }
      end
    end
  end

  def destroy
    @press_article = PressArticle.find params[:id]
    @press_article.destroy
    respond_to do |format|
      format.html { redirect_to admin_press_articles_path, notice: "Supprimé !" }
    end
  end
end
