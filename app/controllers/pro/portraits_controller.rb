class Pro::PortraitsController < Pro::ProController

  before_action :authenticate_pro_super_admin!, except: [:index, :show]
  before_action :load_categories

  layout :get_layout

  def get_layout
    if %w(index show).include?(action_name)
      'admin_pages'
    else
      'admin'
    end
  end

  def list
    @portraits = Portrait.all
  end

  def index
    redirect_to pro_blog_articles_path, status: 301
    @portraits = Portrait.all
  end

  def new
    @portrait = Portrait.new
  end

  def edit
    @portrait = Portrait.find params[:id]
    @medias = @portrait.medias.order('caption ASC')
  end

  def show
    @portrait = Portrait.find params[:id]
    @images = @portrait.medias.order('caption ASC')
  end

  def create
    @portrait = Portrait.new params[:portrait]
    respond_to do |format|
      if @portrait.save
        format.html { redirect_to list_pro_portraits_path }
      else
        format.html { render action: :new }
      end
    end
  end

  def update
    @portrait = Portrait.find params[:id]
    respond_to do |format|
      if @portrait.update_attributes params[:portrait]
        format.html { redirect_to list_pro_portraits_path }
      else
        format.html { render action: :edit }
      end
    end
  end

  private

  def load_categories
    @categories = ::Blog::Category::ProCategory.at_depth(0).order('position ASC NULLS LAST').all
  end

end
