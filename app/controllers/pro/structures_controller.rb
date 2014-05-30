# encoding: utf-8
class Pro::StructuresController < Pro::ProController

  before_action :authenticate_pro_admin!, except: [:select, :new, :create, :get_feedbacks, :widget_ext, :best]
  load_and_authorize_resource :structure, except: [:select, :new, :create, :get_feedbacks, :widget_ext, :best], find_by: :slug

  layout :get_layout

  respond_to :json

  # GET member
  # Set the widget status
  # params
  #   :status
  def update_widget_status
    if params[:status] and Structure::WIDGET_STATUS.include? params[:status]
      @structure.update_column :widget_status, params[:status]
    end
    if params[:status] == 'need_help'
      notice = 'Merci pour votre réponse, notre équipe vous contactera au plus vite pour vous aider'
    else
      notice = 'Merci pour votre réponse.'
    end
    respond_to do |format|
      if @structure.has_installed_widget?
        format.html { redirect_to(dashboard_pro_structure_path(@structure), notice: notice) }
      else
        format.html { redirect_to(widget_pro_structure_path(@structure), notice: notice) }
      end
    end
  end

  # GET member
  def widget
    @structure = Structure.friendly.find params[:id]
    respond_to do |format|
      format.html
    end
  end

  # GET member
  #   format :json
  # Method called from external sites by the widget
  def widget_ext
    @structure = Structure.friendly.find params[:id]
    headers['Access-Control-Allow-Origin']  = '*'
    headers['Access-Control-Allow-Methods'] = 'GET, OPTIONS'
    headers['Access-Control-Max-Age']       = '1728000'
    headers['Access-Control-Allow-Headers'] = 'X-Requested-With, X-Prototype-Version, X-CSRF-Token'
    respond_to do |format|
      format.json { render text: render_to_string(partial: 'pro/structures/widget', layout: false) }
    end
  end

  # GET member
  def widget_jpo
    @structure = Structure.friendly.find params[:id]
    respond_to do |format|
      format.html
    end
  end

  # GET member
  #   format :json
  # Method called from external sites by the widget
  def widget_jpo_ext
    @structure = Structure.friendly.find params[:id]
    headers['Access-Control-Allow-Origin']  = '*'
    headers['Access-Control-Allow-Methods'] = 'GET, OPTIONS'
    headers['Access-Control-Max-Age']       = '1728000'
    headers['Access-Control-Allow-Headers'] = 'X-Requested-With, X-Prototype-Version, X-CSRF-Token'
    respond_to do |format|
      format.json { render text: render_to_string(partial: 'pro/structures/widget_jpo', layout: false) }
    end
  end

  # GET member
  #   format :json
  def wizard
    @wizard = get_next_wizard
    @structure = Structure.friendly.find params[:id]
    respond_to do |format|
      if @wizard
        format.json { render json: { form: render_to_string(partial: @wizard.partial, layout: false, formats: [:html]), done: false }  }
      else
        format.json { render json: { done: true }  }
      end
    end
  end

  # GET member
  def dashboard
    @structure      = Structure.friendly.find params[:id]
    @wizard         = get_next_wizard
    commentable_ids = @structure.courses.map(&:id)
    commentable_ids << @structure.id
    @comments       = @structure.comments.accepted
    @courses        = @structure.courses
    @medias         = @structure.medias.cover_first
    @places         = @structure.places
    @profile_percentage = 100
    @profile_percentage -= 20 if !@structure.profile_completed?
    @profile_percentage -= 20 if @structure.medias.empty?
    @profile_percentage -= 20 if @comments.empty?
    @profile_percentage -= 20 if @structure.courses.active.count == 0

    @json_locations = Gmaps4rails.build_markers(@places) do |place, marker|
      marker.lat place.latitude
      marker.lng place.longitude
    end
  end

  # GET collection
  #   format :json
  # Returns the best structures located near Paris
  # Used on Pro::HomeController#index
  def best
    @admin      = ::Admin.new
    latitude, longitude, radius = 48.8540, 2.3417, 5
    @structures = StructureSearch.search({ lat: latitude,
                                           lng: longitude,
                                           radius: radius,
                                           sort: 'rating_desc',
                                           has_logo: true,
                                           per_page: 30,
                                           bbox: true }).results

    @latlng = StructureSearch.retrieve_location(params)

    respond_to do |format|
      format.json { render json: @structures, root: 'structures', each_serializer: LightStructureSerializer, meta: { total: 50, location: @latlng } }
    end
  end

  # GET collection
  def stars
    @structures = Structure.order('created_at DESC').where { comments_count >= 5 }
  end

  # GET collection
  def index
    @structures = Structure.includes(:admins).where(admins: { structure_id: nil }).order('structures.created_at DESC')
  end

  # GET member
  def show
    @structure = Structure.friendly.find params[:id]
    retrieve_home_places
    render action: :edit
  end

  def add_subjects
    respond_to do |format|
      format.html do
        if request.xhr?
          render partial: 'add_subjects', locals: { return_to: params[:return_to] }
        else
          redirect_to params[:return_to] || new_pro_structure_course_path(@structure)
        end
      end
    end
  end

  def edit
    @structure = Structure.friendly.find(params[:id])
    retrieve_home_places
  end

  def edit_contact
    @structure = Structure.friendly.find(params[:id])
    @admin     = @structure.main_contact
  end

  def new
    session[:name]     = params[:name]
    session[:zip_code] = params[:zip_code]
    session[:email]    = params[:email]
    @structure  = Structure.new name: params[:name], zip_code: params[:zip_code], contact_email: params[:email]
    @structure.places << @structure.places.publics.build
    @structures = Structure.where.not(comments_count: nil).order('comments_count DESC').limit(3)
  end

  def update
    @structure = Structure.friendly.find params[:id]
    @admin     = @structure.main_contact
    if params[:structure] && params[:structure].delete(:delete_logo) == '1'
      @structure.logo.clear
    end

    if params[:structure] && params[:structure][:subject_descendants_ids].present?
      params[:structure][:subject_ids] = params[:structure][:subject_ids] + params[:structure].delete(:subject_descendants_ids)
    end
    respond_to do |format|
      if @structure.update_attributes(params[:structure])
        @structure.logo.reprocess! if @structure.logo.present? && has_cropping_attributes?
        if !request.xhr? && params[:structure][:logo].present?
          format.html { redirect_to (crop_logo_pro_structure_path(@structure)), notice: 'Vos informations ont bien été mises à jour.' }
        else
          format.html { redirect_to (params[:return_to] || edit_pro_structure_path(@structure)), notice: 'Vos informations ont bien été mises à jour.' }
          format.js { render nothing: true }
          format.json do
            render json: { logo: { path: @structure.logo.url(:large) } }
          end
        end
      else
        retrieve_home_places
        if params[:return_to].present?
          format.html { render action: 'edit_contact' }
        else
          format.html { render action: 'edit' }
        end
      end
    end
  end

  def crop_logo
    @structure = Structure.find(params[:id])

    if !@structure.logo.present?
      redirect_to edit_pro_structure_path(@structure), alert: "Vous n'avez pas de logo"
    end
    @is_xhr = request.xhr?
    if request.xhr?
      render layout: false
    end
  end

  def create
    # Merge parent and children subjects
    params[:structure][:subject_ids] = params[:structure][:subject_ids] + params[:structure].delete(:subject_descendants_ids) unless params[:structure][:subject_descendants_ids].blank?
    # Prevents from duplicates
    s_name      = params[:structure][:name]
    s_zip_code  = params[:structure][:zip_code]

    @structure  = Structure.where( Structure.arel_table[:name].eq(s_name).and(
                                   Structure.arel_table[:zip_code].eq(s_zip_code)) ).first_or_initialize params[:structure]

    respond_to do |format|
      if @structure.persisted? # If structure already existed
        format.html { redirect_to new_pro_admin_structure_registration_path(@structure, subdomain: 'pro'), notice: 'Félicitations, votre profil est maintenant créé !<br>Dernière étape : créez vos identifiants.' }
      elsif @structure.new_record? && @structure.save
        format.html { redirect_to new_pro_admin_structure_registration_path(@structure, subdomain: 'pro'), notice: 'Félicitations, votre profil est maintenant créé !<br>Dernière étape : créez vos identifiants.' }
      else
        # Used for showing side structure list on new action
        @structures = Structure.where.not(comments_count: nil).order('comments_count DESC').limit(3)
        format.html { render 'pro/structures/new' }
      end
    end
  end

  def update_and_delete
    @structure.update_attributes(params[:structure])
    AdminMailer.delay.is_about_to_delete(@structure)
    respond_to do |format|
      format.js
    end
  end

  def destroy
    @structure = Structure.friendly.find params[:id]
    AdminMailer.delay.has_destroyed(@structure)
    respond_to do |format|
      if @structure.destroy
        if current_pro_admin.super_admin?
          format.html { redirect_to pro_admins_path, notice: 'Structure supprimé' }
        else
          format.html { redirect_to root_admins_path, notice: 'Vous allez nous manquer...' }
        end
      else
        format.html { redirect_to pro_admins_path, alert: 'Oups...' }
      end
    end
  end

  # GET member
  def ask_for_deletion
    if request.xhr?
      render layout: false
    end
  end

  # GET member
  def premium
  end

  # GET member
  def premium_modal
    if request.xhr?
      render layout: false
    end
  end

  # GET member
  def signature
  end

  # GET member
  def logo
  end

  private

  # Return the next wizard regarding the params passed (skip: true)
  # and wizards that are completed
  #
  # @return Wizard
  def get_next_wizard
    # Return nil if there is no next wizard
    if params[:next] && session[:current_wizard_id] && session[:current_wizard_id] == Structure::Wizard.data.length
      return nil
    # Return the next wizard if it's not completed, else, it increments
    elsif params[:next] && session[:current_wizard_id] && session[:current_wizard_id] < Structure::Wizard.data.length
      session[:current_wizard_id] += 1
      wizard = Structure::Wizard.find(session[:current_wizard_id])
      if wizard.completed?.call(@structure)
        return get_next_wizard
      else
        return wizard
      end
    else
      Structure::Wizard.all.each do |wizard|
        unless wizard.completed?.call(@structure)
          session[:current_wizard_id] = wizard.id
          return wizard
        end
      end
      return nil
    end
  end

  def get_layout
    if action_name == 'new' || action_name == 'create'
      'empty'
    else
      'admin'
    end
  end

  # Check if need to reprocess logo
  def has_cropping_attributes?
    params[:structure][:crop_width].present? || params[:structure][:crop_x].present? || params[:structure][:crop_y].present?
  end

  def retrieve_home_places
    @structure.places.homes.build if @structure.places.homes.empty?
    @home_places = @structure.places.select{ |p| p.type == 'Place::Home' }
  end
end
