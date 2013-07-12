# encoding: utf-8
class ::Pro::AdminsController < InheritedResources::Base
  before_filter :authenticate_pro_admin!, except: [:waiting_for_activation]
  load_and_authorize_resource :admin, except: [:waiting_for_activation]

  layout :admin_layout

  respond_to :js

  def admin_layout
    if action_name == 'waiting_for_activation'
      'admin_pages'
    else
      'admin'
    end
  end

  def waiting_for_activation
  end

  def confirm
    @admin            = ::Admin.find(params[:id])
    respond_to do |format|
      if @admin.confirm!
        format.html { redirect_to pro_admins_path }
      else
        format.html { redirect_to pro_admins_path, alert: 'Something fucked up.' }
      end
    end
  end


  def index
    @admins = ::Admin.order('created_at DESC').all
  end

  def edit
    @admin     = ::Admin.find(params[:id])
    @structure = @admin.structure
  end

  def update
    @admin = ::Admin.find(params[:id])

    if !@admin.new_record? and params[:admin][:password].blank?
      params[:admin].delete :password
      params[:admin].delete :password_confirmation
    end

    respond_to do |format|
      if @admin.update_attributes(params[:admin])
        sign_in(@admin, bypass: true)
        format.html { redirect_to edit_pro_admin_path(current_pro_admin), notice: 'Vos paramètres ont été mis à jour avec succès' }
        format.js { render nothing: true }
      else
        format.html { render 'pro/admins/edit' }
      end
    end
  end

  def destroy
    @admin     = ::Admin.find(params[:id])
    @structure = @admin.structure
    destroy! do |format|
      format.html do
        redirect_to pro_admins_path, notice: 'Admin correctement supprimé.'
      end
    end
  end
end
