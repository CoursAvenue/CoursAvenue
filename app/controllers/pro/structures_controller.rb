# encoding: utf-8
class Pro::StructuresController < Pro::ProController
  before_filter :authenticate_pro_admin!, except: [:select, :new, :create, :get_feedbacks]
  load_and_authorize_resource :structure, except: [:select, :edit, :new, :create, :get_feedbacks]

  layout :get_layout

  respond_to :json

  def crop
    @structure = Structure.find params[:id]
  end

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
    @courses        = @structure.courses
    @medias         = @structure.medias
    @profile_completed = @structure.image.present? and (@structure.description.present? and @structure.description.split.size > 30)
    @profile_percentage = 100
    @profile_percentage -= 20 if !@profile_completed
    @profile_percentage -= 20 if @structure.medias.empty?
    @profile_percentage -= 20 if @comments.empty?
    @profile_percentage -= 20 if @structure.courses.active.count == 0
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
  end

  def edit
    @structure = Structure.find(params[:id])
    @ratio     = 1
    @ratio     = @structure.logo_geometry(:original).width / @structure.logo_geometry(:large).width if @structure.logo?
    @admin     = @structure.admins.first || @structure.admins.build
  end

  def new
    session[:name]     = params[:name]
    session[:zip_code] = params[:zip_code]
    session[:email]    = params[:email]
    @structure  = Structure.new name: params[:name], zip_code: params[:zip_code], contact_email: params[:email]
    @structures = Structure.where{(image_updated_at != nil) & (comments_count != nil)}.order('comments_count DESC').limit(3)
  end

  def update
    @structure = Structure.find params[:id]
    if params[:structure].delete(:delete_image) == '1'
      @structure.image.clear
    end
    if params[:structure].delete(:delete_logo) == '1'
      @structure.logo.clear
    end

    respond_to do |format|
      if @structure.update_attributes(params[:structure])
        if params[:structure][:logo].present?
          format.html { redirect_to crop_pro_structure_path(@structure), notice: 'Vos informations ont bien été mises à jour.' }
        else
          format.html { redirect_to pro_structure_path(@structure), notice: 'Vos informations ont bien été mises à jour.' }
        end
        format.js { render nothing: true }
      else
        format.html { render action: 'edit' }
      end
    end
  end


  def create
    # Prevents from duplicates
    s_name      = params[:structure][:name]
    s_zip_code  = params[:structure][:zip_code]
    @structure  = Structure.where{(name == s_name) & (zip_code == s_zip_code)}.first
    @structures = Structure.where{(image_updated_at != nil) & (comments_count != nil)}.order('comments_count DESC').limit(3)
    place_name = params[:structure][:location].delete :name
    params[:structure].delete :location
    if @structure.nil?
      @structure = Structure.new params[:structure]
    end
    respond_to do |format|
      if !@structure.new_record? or @structure.save
        @structure.create_place(place_name)
        session[:id] = @structure.id
        format.html { redirect_to new_pro_admin_structure_registration_path(@structure, subdomain: 'pro'), notice: 'Félicitation, votre profil est maintenant créé !<br>Dernière étape : créez vos identifiants.' }
      else
        format.html { render 'pro/structures/new' }
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
    if params[:next] and session[:current_wizard_id] and session[:current_wizard_id] <= Wizard.data.length
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
    if action_name == 'new' or action_name == 'create'
      'empty'
    else
      'admin'
    end
  end
end
