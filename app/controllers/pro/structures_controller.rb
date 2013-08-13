# encoding: utf-8
class Pro::StructuresController < Pro::ProController
  before_filter :authenticate_pro_admin!, except: [:select, :new, :create, :create_and_get_feedbacks, :import_mail_callback, :import_mail_callback_failure, :share_my_profile, :get_feedbacks]
  load_and_authorize_resource :structure, except: [:select, :edit, :new, :create, :get_feedbacks, :create_and_get_feedbacks, :import_mail_callback, :import_mail_callback_failure, :share_my_profile]

  layout :get_layout

  respond_to :json

  def wizard
    @wizard = get_next_wizard
    @structure = Structure.find params[:id]
    respond_to do |format|
      if @wizard
        format.json { render json: { form: render_to_string(partial: @wizard.partial, layout: false), done: false }  }
      else
        format.json { render json: { done: true }  }
      end
    end
  end

  def dashboard
    @structure      = Structure.find params[:id]
    @wizard         = get_next_wizard
    commentable_ids = @structure.courses.collect(&:id)
    commentable_ids << @structure.id
    @comments       = @structure.all_comments
    @comments_group = Comment.where{commentable_id.in commentable_ids }.count(:order => "DATE_TRUNC('week', created_at) ASC", :group => ["DATE_TRUNC('week', created_at)"])
    @structure_better_indexed = {}
    structure_comment_count  = @structure.comments_count
    @structure.parent_subjects_string.split(';').each do |parent_subject_string|
      subject_name = parent_subject_string.split(',')[0]
      @structure_better_indexed[subject_name] = Structure.where{(parent_subjects_string =~ "%#{parent_subject_string}%") & (comments_count > structure_comment_count)}.order('comments_count DESC').limit(8)
    end

    @profile_completed = @structure.image.present? and (@structure.description.present? and @structure.description.split.size > 30)
    @profile_percentage = 100
    @profile_percentage -= 25 if !@profile_completed
    @profile_percentage -= 25 if @structure.medias.empty?
    @profile_percentage -= 25 if @comments.empty?
    @profile_percentage -= 25 if @structure.courses.active.count == 0
  end

  def share_my_profile
    @structure = Structure.find params[:id]
  end

  def import_mail_callback_failure
    redirect_to inscription_pro_structures_path
  end

  def get_feedbacks
    @structure      = Structure.find params[:id]
    params[:emails] ||= ''
    emails          = params[:emails].split(',').map(&:strip)
    emails.each do |email|
      StudentMailer.delay.ask_for_feedbacks(@structure, email)
    end
    respond_to do |format|
      format.html { redirect_to params[:redirect_to] || recommendations_pro_structure_path(@structure), notice: (params[:emails].present? ? 'Vos élèves ont bien été notifiés': nil)}
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
    @courses   = @structure.courses.order('name ASC')
    respond_to do |format|
      if @structure.places.empty?
        format.html { redirect_to new_pro_structure_place_path(@structure), notice: "Vous devez d'abord créé des lieux pour vos cours."}
      else
        format.html
      end
    end
  end

  def edit
    @structure = Structure.find(params[:id])
    @admin     = @structure.admins.first || @structure.admins.build
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

  def new
    session[:name]     = params[:name]
    session[:zip_code] = params[:zip_code]
    session[:email]    = params[:email]
    @structure  = Structure.new name: params[:name], zip_code: params[:zip_code], contact_email: params[:email]
    @structures = Structure.where{(image_updated_at != nil) & (comments_count != nil)}.order('comments_count DESC').limit(8)
  end

  def update
    @structure = Structure.find params[:id]
    if params[:structure].delete(:delete_image) == '1'
      @structure.image.clear
    end

    respond_to do |format|
      if @structure.update_attributes(params[:structure])
        format.html { redirect_to edit_pro_structure_path(@structure), notice: 'Vos informations ont bien été mises à jour.' }
        format.js { render nothing: true }
      else
        format.html { render action: 'edit' }
      end
    end
  end

  def create_and_get_feedbacks
    # Prevents from duplicates
    s_name      = params[:structure][:name]
    s_zip_code  = params[:structure][:zip_code]
    @structure  = Structure.where{(name == s_name) & (zip_code == s_zip_code)}.first
    @structures = Structure.where{(image_updated_at != nil) & (comments_count != nil)}.order('comments_count DESC').limit(8)
    if @structure.nil?
      @structure = Structure.new params[:structure]
    end
    respond_to do |format|
      if !@structure.new_record? or @structure.save
        session[:id] = @structure.id
        format.html { redirect_to new_pro_admin_structure_registration_path(@structure, subdomain: 'pro'), notice: 'Félicitation, votre profil est maintenant créé !<br>Dernière étape : créez vos identifiants.' }
      else
        format.html { render 'pro/structures/new' }
      end
    end
  end

  def create
    @admin            = ::Admin.new params[:admin]
    @structure        = Structure.new(params[:structure])
    @structure.admins << @admin
    @admin.structure  = @structure
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
  def get_next_wizard
    if params[:next] and session[:current_wizard_id]
      session[:current_wizard_id] += 1
      return Wizard.find(session[:current_wizard_id])
    else
      Wizard.all.each do |wizard|
        unless wizard.completed?.call(@structure)
          session[:current_wizard_id] = wizard.id
          return wizard
        end
      end
      return nil
    end
  end

  def get_layout
    if action_name == 'new' or action_name == 'create_and_get_feedbacks' or action_name == 'import_mail_callback' or action_name == 'share_my_profile'
      'empty'
    else
      'admin'
    end
  end
end
