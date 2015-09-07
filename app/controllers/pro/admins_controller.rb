# encoding: utf-8
class ::Pro::AdminsController < InheritedResources::Base
  before_action :authenticate_pro_admin!, except: [:waiting_for_activation, :facebook_auth_callback, :facebook_auth_failure]
  load_and_authorize_resource :admin, except: [:waiting_for_activation, :show, :facebook_auth_callback, :facebook_auth_failure], find_by: :slug

  layout :get_layout

  respond_to :js, :json

  def show
    redirect_to pro_root_path
  end

  def unsubscribe
    if admin = Admin.read_access_token(params[:signature])
      admin.update_attribute :email_opt_in, false
      redirect_to pro_structure_path(admin.structure), notice: 'Vous avez bien été desinscrit de la liste.'
    else
      redirect_to pro_structure_path(admin.structure), notice: 'Lien invalide.'
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
    @admins = Admin.order('created_at DESC').page(params[:page])
    respond_to do |format|
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

    if !@admin.new_record? && params[:admin][:password].blank?
      params[:admin].delete :password
      params[:admin].delete :password_confirmation
    end
    @structure = @admin.structure
    respond_to do |format|
      if @admin.update_attributes(params[:admin])
        sign_in(@admin, bypass: true)
        format.html { redirect_to edit_pro_admin_path(@admin), notice: 'Vos paramètres ont été mis à jour avec succès' }
        format.js { render nothing: true }
      else
        format.html { render action: :edit }
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

  def facebook_auth_callback
    structure = Structure.where(slug: params[:structure_id]).first
    auth      = request.env['omniauth.auth']

    @admin    = Admin.from_omniauth(auth, structure)

    if @admin and @admin.persisted?
      flash[:notice] = I18n.t 'devise.omniauth_callbacks.success', kind: 'Facebook'

      # Update oauth.
      @admin.oauth_token      = auth.credentials.token
      @admin.oauth_expires_at = Time.at(auth.credentials.expires_at)

      # Sign Admin in using Devise.
      sign_in(Devise::Mapping.find_scope!(@admin), @admin, event: :authentication)

      respond_to do |format|
        format.json { render json: { id: @admin.id, structure_id: @admin.structure.id, slug: @admin.structure.slug, redirect_url: after_omni_auth_sign_in_path_for(@admin) } }
        format.html { redirect_to dashboard_pro_structure_path(structure) }
      end
    else
      respond_to do |format|
        format.json { render json: { redirect_url: inscription_pro_structures_path, message: "Nous n'avons pas pu vous connecter. Assurez-vous d'être bien connecté à Facebook et réessayez." }, status: 422 }
        format.html { redirect_to pro_auth_failure_path }
      end
    end
  end

  def facebook_auth_failure
    message = I18n.t('devise.omniauth_callbacks.failure', kind: 'Facebook')
    respond_to do |format|
      format.json { render json: { message: message }, status: 422 }
      format.html { redirect_to pro_premium_path, flash: { message: message } }
    end
  end

  private

  def after_omni_auth_sign_in_path_for(admin)
    if admin.sign_in_count == 1
      edit_pro_structure_path(admin.structure)
    else
      session['pro_admin_return_to'].gsub('__STRUCTURE_ID__', admin.structure.slug) if session['pro_admin_return_to'].present? and admin.structure.present?
      session['pro_admin_return_to'] || dashboard_pro_structure_path(admin.structure)
    end
  end

  def get_layout
    if action_name == 'waiting_for_activation'
      'empty'
    else
      'admin'
    end
  end

end
