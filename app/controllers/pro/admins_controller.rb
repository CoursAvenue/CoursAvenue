# encoding: utf-8
class ::Pro::AdminsController < InheritedResources::Base
  before_filter :authenticate_pro_admin!
  authorize_resource ::Admin

  layout 'admin'

  def activate
    @admin            = ::Admin.find(params[:id])
    @structure        = @admin.structure
    @admin.active     = true
    @structure.active = true
    respond_to do |format|
      if @admin.save and @structure.save
        @structure.places.map(&:index)
        AdminMailer.admin_validated(@admin).deliver!
        format.html { redirect_to pro_admins_path }
      else
        format.html { redirect_to pro_admins_path, alert: 'Something fucked up.' }
      end
    end
  end

  def disable
    @admin = ::Admin.find(params[:id])
    @admin.update_attribute :active, false
    respond_to do |format|
      format.html { redirect_to pro_admins_path }
    end
  end

  def index
    @admins = ::Admin.order('created_at DESC').all
  end

  def edit
    @admin = ::Admin.find(params[:id])
  end

  def update
    @admin = ::Admin.find(params[:id])
    update! do |format|
      format.html do
        if current_pro_admin.super_admin?
          redirect_to pro_admins_path
        else
          redirect_to pro_structure_path current_pro_admin.structure
        end
      end
    end
  end

  def destroy
    @admin = ::Admin.find(params[:id])
    destroy! do |format|
      format.html do
        redirect_to pro_admins_path, notice: 'Admin correctement supprimé.'
      end
    end
  end
end
