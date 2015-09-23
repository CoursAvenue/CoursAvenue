# encoding: utf-8
class Pro::Structures::WebsitePages::ArticlesController < Pro::ProController
  layout 'admin'

  before_action :authenticate_pro_admin!
  load_and_authorize_resource :structure, find_by: :slug
  before_action :set_page

  def index
    @pages = @structure.website_pages
  end

  def show
    @article = @website_page.articles.find(params[:id])
  end

  def edit
    @article = @website_page.articles.find(params[:id])
  end

  def new
    @article = @website_page.articles.build
  end

  def create
    @article = @website_page.articles.build(article_params)
    respond_to do |format|
      if @article.save
        format.html { redirect_to pro_reservation_pages_path(@structure) }
      else
        format.html { render action: :new }
      end
    end
  end

  def update
    @article = @website_page.articles.find(params[:id])
    respond_to do |format|
      if @article.update_attributes(article_params)
        format.html { redirect_to pro_reservation_pages_path(@structure) }
      else
        format.html { render action: :edit }
      end
    end
  end

  def destroy
    @article = @website_page.articles.find(params[:id])
    @article.destroy
    redirect_to pro_reservation_pages_path(@structure)
  end

  private

  def article_params
    params.require(:website_page_article).permit(:title, :content)
  end

  private

  def set_page
    @website_page = @structure.website_pages.find params[:website_page_id]
  end
end
