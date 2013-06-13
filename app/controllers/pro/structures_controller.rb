# encoding: utf-8
class Pro::StructuresController < Pro::ProController
  before_filter :authenticate_pro_admin!, except: [:select, :new, :create, :new_from_recomendation, :create_and_get_feedbacks, :import_mail_callback, :import_mail_callback_failure, :share_my_profile, :get_feedbacks]
  load_and_authorize_resource :structure, except: [:select, :edit, :new, :create, :get_feedbacks, :new_from_recomendation, :create_and_get_feedbacks, :import_mail_callback, :import_mail_callback_failure, :share_my_profile]

  layout :get_layout

  def share_my_profile
    @structure = Structure.find params[:id]
  end

  def import_mail_callback_failure
    redirect_to new_from_recomendation_pro_structures_path
  end

  def get_feedbacks
    @structure      = Structure.find params[:id]
    params[:emails] ||= ''
    emails          = params[:emails].split(',').map(&:strip)
    emails.each do |email|
      StudentMailer.delay.ask_for_feedbacks(@structure, email)
    end
    respond_to do |format|
      format.html { redirect_to params[:redirect_to] || recommendations_pro_structure_path(@structure), notice: (params[:emails].present? ? 'Vos élèves ont bien été notifiés': nil)}
    end
  end

  def select
    structure_with_admin  = Structure.select(:id).joins(:admins)
    @structures           = Structure.where{id.not_in structure_with_admin}.order('name ASC').all
  end

  def disable_condition
    @structure        = Structure.find params[:id]
    @structure.update_attribute :has_validated_conditions, false
    @structure.update_attribute :validated_by, nil
    respond_to do |format|
      format.html { redirect_to awaiting_pro_structures_path }
    end
  end

  def validate_condition
    @structure        = Structure.find params[:id]
    respond_to do |format|
      if @structure.update_attributes params[:structure]
        format.html { redirect_to pro_structure_path(@structure), notice: "Nous avons bien été avertis. Nous revenons vers vous dans les meilleurs délais." }
      else
        format.html { redirect_to edit_pro_structure_path(@structure), alert: "Vous devez remplir toutes vos informations" }
      end
    end
  end

  def activate
    @structure        = Structure.find params[:id]
    respond_to do |format|
      if @structure.activate!
        format.html { redirect_to pro_structures_path }
      else
        format.html { redirect_to pro_structures_path, alert: 'Les informations de la structure ne sont pas complètes.' }
      end
    end
  end

  def disable
    @structure        = Structure.find params[:id]
    respond_to do |format|
      if @structure.disable!
        format.html { redirect_to pro_structures_path }
      else
        format.html { redirect_to pro_structures_path, alert: 'Les informations de la structure ne sont pas complètes.' }
      end
    end
  end

  def index
    @structures = Structure.order('created_at ASC').all
  end

  def show
    @structure = Structure.find params[:id]
    @places    = @structure.places.order('name ASC')
    respond_to do |format|
      if @structure.places.empty?
        format.html { redirect_to new_pro_structure_place_path(@structure), notice: "Vous devez d'abord créé des lieux pour vos cours."}
      # elsif @courses.empty?
      #   format.html{ redirect_to new_pro_structure_course_path(@structure) }
      else
        format.html
      end
    end
  end

  def edit
    @structure = Structure.find(params[:id])
    @admin     = @structure.admins.first || @structure.admins.build
    if ! can? :edit, @structure
      redirect_to pro_structure_path(@structure), alert: "Votre compte n'est pas encore activé, vous ne pouvez pas éditer les informations générales"
    end
  end

  def import_mail_callback
    if session[:id].present?
      @structure = Structure.find session[:id]
    else
      @structure = Structure.last
    end
    @contacts = request.env['omnicontacts.contacts'].reject{|contact| contact[:email].blank?}
    render action: 'share_my_profile'
  end

  def new_from_recomendation
    session[:name]     = params[:name]
    session[:zip_code] = params[:zip_code]
    session[:email]    = params[:email]
    @structure = Structure.new name: params[:name], zip_code: params[:zip_code], contact_email: params[:email]
  end

  def new
    @structure = Structure.new
  end

  def update
    @structure = Structure.find params[:id]
    if params[:structure].delete(:delete_image) == '1'
      resource.image.clear
    end
    @admin     = (params[:admin][:id].blank? ? ::Admin.new : ::Admin.find(params[:admin].delete(:id)))
    @structure.admins << @admin

    if !@admin.new_record? and params[:admin][:password].blank?
      params[:admin].delete :password
      params[:admin].delete :password_confirmation
    end

    has_saved = @admin.update_attributes(params[:admin])

    respond_to do |format|
      has_saved = has_saved && @structure.update_attributes(params[:structure])
      if has_saved
        format.html { redirect_to edit_pro_structure_path @structure }
      else
        format.html { render action: 'edit' }
      end
    end
  end

  def create_and_get_feedbacks
    @structure      = Structure.new params[:structure]
    respond_to do |format|
      if @structure.save
        session[:id] = @structure.id
        format.html { redirect_to share_my_profile_pro_structure_path(@structure), notice: 'Partagez maintenant votre profil public pour avoir des recommandations' }
      else
        format.html { render 'pro/structures/new_from_recomendation' }
      end
    end

  end

  def create
    @admin           = ::Admin.new params[:admin]
    @structure       = Structure.new(params[:structure])
    @structure.admins << @admin
    @admin.structure = @structure
    respond_to do |format|
      if @structure.valid? and @admin.valid?
        @structure.save
        @admin.save
        format.html { redirect_to waiting_for_activation_pro_admins_path, notice: 'Un email de confirmation vient de vous être envoyé' }
      else
        flash[:alert] = 'Il nous manque quelques informations pour continuer'
        format.html { render action: 'new'}
      end
    end
  end

  def destroy
    @structure = Structure.find params[:id]
    respond_to do |format|
      if @structure.destroy
        format.html { redirect_to pro_structures_path, notice: 'Structure supprimé' }
      else
        format.html { redirect_to pro_structures_path, alert: 'Oups...' }
      end
    end
  end

  private

  def get_layout
    if action_name == 'new_from_recomendation' or action_name == 'create_and_get_feedbacks' or action_name == 'import_mail_callback' or action_name == 'share_my_profile'
      'empty'
    else
      'admin'
    end
  end
end
