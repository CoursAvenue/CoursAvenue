# encoding: utf-8
class ::Pro::AdminsController < InheritedResources::Base
  helper :all

  before_action :authenticate_pro_admin!, except: [:waiting_for_activation]
  load_and_authorize_resource :admin, except: [:waiting_for_activation], find_by: :slug

  layout :admin_layout

  respond_to :js, :json

  def unsubscribe
    if admin = Admin.read_access_token(params[:signature])
      admin.update_attribute :email_opt_in, false
      redirect_to pro_structure_path(admin.structure), notice: 'Vous avez bien été desinscrit de la liste.'
    else
      redirect_to pro_structure_path(admin.structure), notice: 'Lien invalide.'
    end
  end

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
    @admin = ::Admin.find(params[:id])
    respond_to do |format|
      if @admin.confirm!
        format.html { redirect_to pro_admins_path }
      else
        format.html { redirect_to pro_admins_path, alert: 'Admin could not have been confirmed.' }
      end
    end
  end

  def index
    @admins = ::AdminSearch.search(params).results
    respond_to do |format|
      format.json { render json: @admins.to_json(include: :structure) }
      format.html
    end
  end

  def edit
    @admin     = ::Admin.find(params[:id])
    @structure = @admin.structure
    if @structure.nil?
      redirect_to request.referrer || root_path, alert: "Pas d'admin pour cet établissement"
    end
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
        format.html { redirect_to edit_pro_admin_path(@admin), notice: 'Vos paramètres ont été mis à jour avec succès' }
        format.js { render nothing: true }
      else
        format.html { render 'pro/admins/edit' }
      end
    end
  end

  def destroy
    @admin     = ::Admin.find(params[:id])
    @structure = @admin.structure
    if params[:delete_structure]
      @structure.destroy
    end
    destroy! do |format|
      format.html do
        redirect_to pro_admins_path, notice: 'Admin correctement supprimé.'
      end
    end
  end
end
