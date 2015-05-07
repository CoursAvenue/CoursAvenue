# encoding: utf-8
class Pro::Structures::AdminsController < Pro::ProController
  layout 'admin'

  before_action :authenticate_pro_admin!
  load_and_authorize_resource :structure, find_by: :slug

  def show
    @admin     = @structure.admins.find(params[:id])
    redirect_to edit_pro_structure_admin_path(@structure, @admin)
  end

  def edit
    @admin     = @structure.admins.find(params[:id])
  end

  def modify_email
    @admin     = @structure.admins.find(params[:id])
    render layout: false
  end

  def notifications
    @admin = @structure.admins.find(params[:id])
    redirect_to edit_pro_structure_admin_path(@structure, @admin)
  end

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
        format.js
        format.html { redirect_to (params[:return_to] || edit_structure_admin_path(@structure, @admin)), notice: 'Les changements ont bien été pris en compte' }
      else
        format.js
        format.html { render 'pro/structures/admins/edit' }
      end
    end
  end
end
