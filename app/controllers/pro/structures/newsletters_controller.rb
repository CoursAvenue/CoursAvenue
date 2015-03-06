class Pro::Structures::NewslettersController < ApplicationController
  before_action :authenticate_pro_admin!
  before_action :set_structure
  before_action :set_layouts, only: [:new, :edit]

  layout 'admin'

  def index
    @newsletters = @structure.newsletters
  end

  def new
  end

  def show
    @newsletter = @structure.newsletters.includes(:blocs).find params[:id]
  end

  def create
    @newsletter = @structure.newsletters.new params[:newsletter]

    respond_to do |format|
      if @newsletter.save
        format.html { redirect_to pro_structure_newsletter_path(@structure, @newsletter),
                      notice: 'Bien enregistré' }
      else
        format.html { render action: :edit }
      end
    end
  end

  def edit
    @newsletter = @structure.newsletters.includes(:blocs).find params[:id]
  end

  def update
    @newsletter = @structure.newsletters.includes(:blocs).find params[:id]
    respond_to do |format|
      if @newsletter.update_attributes params[:newsletter]
        format.html { redirect_to pro_structure_newsletter_path(@structure, @newsletter),
                      notice: 'Bien enregistré' }
      else
        format.html { render action: :edit }
      end
    end
  end

  # TODO: Fix error message..
  def destroy
    @newsletter = @structure.newsletters.includes(:blocs).find params[:id]

    respond_to do |format|
      if @newsletter.destroy
        format.html { redirect_to pro_structure_newsletters_path(@newsletter), notice: 'Supprimé' }
      else
        format.html { redirect_to pro_structure_newsletters_path(@newsletter), notice: 'Error' }
      end
    end
  end

  # TODO:
  # 1. Check all of the required informations are given.
  # 2. Generate the newsletter content.
  # 3. Send the newsletter to the associated mailing list.
  def send
    @newsletter = @structure.newsletters.includes(:blocs).find params[:id]
  end

  private

  def set_structure
    @structure = Structure.includes(:newsletters).find(params[:structure_id])
  end

  def set_layouts
    @layouts = Newsletter::Layout.all.as_json.map do |layout|
      layout["attributes"]
    end
  end

  def required_params
    params.require(:newsletter).permit(:title, :layout_id, :bloc_attributes)
  end
end
