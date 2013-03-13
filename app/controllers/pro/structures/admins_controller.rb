# encoding: utf-8
class Pro::Structures::AdminsController < Pro::ProController

  layout 'admin'

  before_filter :retrieve_structure

  def create
    @admin = ::Admin.new(params[:admin])
    @admin.structure = @structure

    respond_to do |format|
      if @admin.save
        format.html { redirect_to structure_path @structure }
      else
        format.html { render 'pro/structures/edit' }
      end
    end
  end

  def update
    @admin = ::Admin.find(params[:id])
    if params[:admin][:password].blank?
      params[:admin].delete :password
      params[:admin].delete :password_confirmation
    end
    respond_to do |format|
      if @admin.update_attributes params[:admin]
        format.html { redirect_to structure_path @structure }
      else
        format.html { render 'pro/structures/edit' }
      end
    end
  end

  private
  def retrieve_structure
    @structure = ::Structure.find(params[:structure_id])
  end
end
