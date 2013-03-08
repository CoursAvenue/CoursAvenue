# encoding: utf-8
class Pro::AdminsController < InheritedResources::Base

  layout 'admin'

  def index
    @admins = Admin.all
  end

  def update
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
