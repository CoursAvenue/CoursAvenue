# encoding: utf-8
class ::Pro::AdminsController < InheritedResources::Base

  layout 'admin'

  def index
    @admins = ::Admin.all
  end

  def edit
    @admin = ::Admin.find(params[:id])
  end

  def update
    @admin = ::Admin.find(params[:id])
    update! do |format|
      format.html do
        if current_admin.super_admin?
          redirect_to admins_path
        else
          redirect_to structure_path current_admin.structure
        end
      end
    end
  end

  def destroy
    @admin = ::Admin.find(params[:id])
    destroy! do |format|
      format.html do
        if current_admin.super_admin?
          redirect_to admins_path
        else
          redirect_to structure_path current_admin.structure
        end
      end
    end
  end
end
