# encoding: utf-8
class Pro::StructuresController < Pro::ProController
  before_action :authenticate_pro_admin!, except: [:select, :new, :create, :get_feedbacks, :widget_ext, :best]
  load_and_authorize_resource :structure, except: [:select, :new, :create, :get_feedbacks, :widget_ext, :best], find_by: :slug

  layout :get_layout

  respond_to :json

  def invite_students
  end

  def invite_students_entourage
    params[:emails] ||= ''
    regexp = Regexp.new(/\b[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}\b/)
    emails = params[:emails].scan(regexp).uniq
    text = '<p>' + params[:text].gsub(/\r\n/, '</p><p>') + '</p>' if params[:text].present?

    emails.each do |student_email|
      AdminMailer.delay.invite_students_entourage(student_email, text, @structure)
    end

    respond_to do |format|
      format.html { redirect_to invite_students_pro_structure_path(@structure), notice: (params[:emails].present? ? 'Vos élèves ont bien été notifiés.' : nil) }
    end
  end

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

  def signature
  end

  def widget
    @structure = Structure.friendly.find params[:id]
    respond_to do |format|
      format.html
    end
  end

  # Method called from external sites by the widget
  def widget_ext
    # TODO protect
    @structure = Structure.friendly.find params[:id]
    headers['Access-Control-Allow-Origin']  = '*'
    headers['Access-Control-Allow-Methods'] = 'GET, OPTIONS'
    headers['Access-Control-Max-Age']       = '1728000'
    headers['Access-Control-Allow-Headers'] = 'X-Requested-With, X-Prototype-Version, X-CSRF-Token'
    respond_to do |format|
      format.json { render text: render_to_string(partial: 'pro/structures/widget', layout: false) }
    end
  end

  def crop
    @structure = Structure.friendly.find params[:id]
  end

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

  def dashboard
    @structure      = Structure.friendly.find params[:id]
    @wizard         = get_next_wizard
    commentable_ids = @structure.courses.map(&:id)
    commentable_ids << @structure.id
    @comments       = @structure.comments.accepted
    @courses        = @structure.courses
    @medias         = @structure.medias.cover_first
    @locations      = @structure.locations
    @profile_percentage = 100
    @profile_percentage -= 20 if !@structure.profile_completed?
    @profile_percentage -= 20 if @structure.medias.empty?
    @profile_percentage -= 20 if @comments.empty?
    @profile_percentage -= 20 if @structure.courses.active.count == 0

    @json_locations = Gmaps4rails.build_markers(@locations) do |location, marker|
      marker.lat location.latitude
      marker.lng location.longitude
    end

    respond_to do |format|
      if can? :manage, @structure
        format.html
      else
        format.html { redirect_to root_path error: "Vous n'êtes pas autorisé à gérer la structure d'autres utilisateurs" }
      end
    end
  end

  def select
    structure_with_admin  = Structure.select(:id).joins(:admins)
    @structures           = Structure.where { id.not_in structure_with_admin }.order('name ASC').all
  end

  def activate
    @structure        = Structure.friendly.find params[:id]
    respond_to do |format|
      if @structure.activate!
        format.html { redirect_to pro_structures_path }
      else
        format.html { redirect_to pro_structures_path, alert: 'Les informations de la structure ne sont pas complètes.' }
      end
    end
  end

  def disable
    @structure        = Structure.friendly.find params[:id]
    respond_to do |format|
      if @structure.disable!
        format.html { redirect_to pro_structures_path }
      else
        format.html { redirect_to pro_structures_path, alert: 'Les informations de la structure ne sont pas complètes.' }
      end
    end
  end

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

  def stars
    @structures = Structure.order('created_at DESC').where { comments_count >= 5 }
  end

  def index
    @structures = Structure.includes(:admins).where(admins: { structure_id: nil }).order('structures.created_at DESC')
  end

  def show
    @structure = Structure.friendly.find params[:id]
    @courses   = @structure.courses.order('name ASC')
  end

  def add_subjects
    if request.xhr?
      render partial: 'add_subjects', locals: { return_to: params[:return_to] }
    end
  end

  def edit
    @structure = Structure.friendly.find(params[:id])
  end

  def new
    session[:name]     = params[:name]
    session[:zip_code] = params[:zip_code]
    session[:email]    = params[:email]
    @structure  = Structure.new name: params[:name], zip_code: params[:zip_code], contact_email: params[:email]
    @structures = Structure.where { (comments_count != nil) }.order('comments_count DESC').limit(3)
  end

  def update
    @structure = Structure.friendly.find params[:id]
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
        format.html { render action: 'edit' }
      end
    end
  end

  def crop_logo
    @structure = Structure.find(params[:id])
    if !@structure.logo.present?
      redirect_to edit_pro_structure_path(@structure), alert: "Vous n'avez pas de logo"
    end
  end

  def create
    # Merge parent and children subjects
    params[:structure][:subject_ids] = params[:structure][:subject_ids] + params[:structure].delete(:subject_descendants_ids) unless params[:structure][:subject_descendants_ids].blank?
    # Prevents from duplicates
    s_name      = params[:structure][:name]
    s_zip_code  = params[:structure][:zip_code]
    @structure  = Structure.where { (name == s_name) & (zip_code == s_zip_code) }.first
    # Used for showing side structure list on new action
    @structures = Structure.where { (comments_count != nil) }.order('comments_count DESC').limit(3)
    @place_name = params[:structure][:location].delete :name
    params[:structure].delete :location
    if @structure.nil?
      @structure = Structure.new params[:structure]
    end
    respond_to do |format|
      if @structure.persisted?
        format.html { redirect_to new_pro_admin_structure_registration_path(@structure, subdomain: 'pro'), notice: 'Félicitations, votre profil est maintenant créé !<br>Dernière étape : créez vos identifiants.' }
      elsif @structure.new_record? && @structure.save
        @structure.create_place(@place_name) unless @structure.places.any?
        format.html { redirect_to new_pro_admin_structure_registration_path(@structure, subdomain: 'pro'), notice: 'Félicitations, votre profil est maintenant créé !<br>Dernière étape : créez vos identifiants.' }
      else
        format.html { render 'pro/structures/new' }
      end
    end
  end

  def destroy
    @structure = Structure.friendly.find params[:id]
    respond_to do |format|
      if @structure.destroy
        format.html { redirect_to pro_admins_path, notice: 'Structure supprimé' }
      else
        format.html { redirect_to pro_admins_path, alert: 'Oups...' }
      end
    end
  end

  private

  def get_next_wizard
    # Return nil if there is no next wizard
    if params[:next] && session[:current_wizard_id] && session[:current_wizard_id] == Wizard.data.length
      return nil
    # Return the next wizard if it's not completed, else, it increments
    elsif params[:next] && session[:current_wizard_id] && session[:current_wizard_id] < Wizard.data.length
      session[:current_wizard_id] += 1
      wizard = Wizard.find(session[:current_wizard_id])
      if wizard.completed?.call(@structure)
        return get_next_wizard
      else
        return wizard
      end
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
end
