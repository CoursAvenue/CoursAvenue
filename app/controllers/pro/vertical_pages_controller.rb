# encoding: utf-8
class Pro::VerticalPagesController < InheritedResources::Base
  before_action :authenticate_pro_admin!

  layout 'admin'

  def index
    if params[:name].present?
      @vertical_pages = VerticalPage.where(VerticalPage.arel_table[:subject_name].matches("%#{params[:name]}%").or(
                                           VerticalPage.arel_table[:title].matches("%#{params[:name]}%"))).order('content DESC').page(params[:page] || 1).per(50)
    else
      @vertical_pages = VerticalPage.order('content DESC').page(params[:page] || 1).per(50)
    end
  end

  def new
    @vertical_page = VerticalPage.new
  end

  def create
    @vertical_page = VerticalPage.new params[:vertical_page]
    respond_to do |format|
      if @vertical_page.save
        format.html { redirect_to pro_vertical_pages_path, notice: 'Bien enregistré' }
      else
        format.html { render action: :edit }
      end
    end
  end

  def edit
    @vertical_page = VerticalPage.friendly.find(params[:id])
  end

  def update
    @vertical_page = VerticalPage.friendly.find(params[:id])
    respond_to do |format|
      if @vertical_page.update_attributes params[:vertical_page]
        format.html { redirect_to pro_vertical_pages_path, notice: 'Bien enregistré' }
      else
        format.html { render action: :edit }
      end
    end
  end

  def destroy
    @vertical_page = VerticalPage.friendly.find(params[:id])
    respond_to do |format|
      if @vertical_page.destroy
        format.html { redirect_to pro_vertical_pages_path, notice: 'Supprimé' }
      else
        format.html { redirect_to pro_vertical_pages_path, error: 'Il y eu un problème' }
      end
    end
  end

end
