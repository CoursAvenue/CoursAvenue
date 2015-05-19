# encoding: utf-8
class Pro::Structures::WebsitePagesController < Pro::ProController
  layout 'admin'

  before_action :authenticate_pro_admin!
  load_and_authorize_resource :structure, find_by: :slug

  def index
    @pages = @structure.website_pages
  end

  def show
    @page = @structure.website_pages.find(params[:id])
  end

  def edit
    @page = @structure.website_pages.find(params[:id])
  end

  def new
    @page = @structure.website_pages.build
    @page.articles.build
  end

  def create
    @website_page = @structure.website_pages.build(website_page_params)
    respond_to do |format|
      if @website_page.save
        format.html { redirect_to pro_structure_website_pages_path(@structure) }
      else
        format.html { render action: :new }
      end
    end
  end

  def update
    @website_page = @structure.website_pages.find(params[:id])
    respond_to do |format|
      if @website_page.update_attributes(website_page_params)
        format.html { redirect_to pro_structure_website_pages_path(@structure) }
      else
        format.html { render action: :edit }
      end
    end
  end

  def destroy
    @website_page = @structure.website_pages.find(params[:id])
    @website_page.destroy
    redirect_to pro_structure_website_pages_path(@structure)
  end

  private

  def website_page_params
    params.require(:website_page).permit(:title, articles_attributes: [:title, :content])
  end
end
