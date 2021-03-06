# encoding: utf-8
class Pro::StructuresController < Pro::ProController
  before_action :authenticate_pro_super_admin!, only: [:new_sleeping]

  before_action :authenticate_pro_admin!, except: [:new, :create, :widget_ext, :best,
                                                   :someone_already_took_control]

  before_action :load_structure

  authorize_resource :structure, except: [:new, :new_sleeping, :create,
                                          :widget_ext, :best,
                                          :someone_already_took_control]

  # We add update in case the update fails and we need the variable in the view
  before_action :retrieve_facebook_pages, only: [:edit_contact, :update]

  layout :get_layout

  respond_to :json

  def export
    respond_to do |format|
      format.xlsx
    end
  end

  def export_active_users
    @page  = (params[:page].present? ? params[:page].to_i : 1)
    @limit = (params[:limit].present? ? params[:limit].to_i : 5000)
    respond_to do |format|
      format.xlsx
    end
  end

  def export_inactive_users
    @page  = (params[:page].present? ? params[:page].to_i : 1)
    @limit = (params[:limit].present? ? params[:limit].to_i : 10000)
    respond_to do |format|
      format.xlsx
    end
  end

  # GET member
  def dashboard
    @structure_decorator = @structure.decorate
    @wizard              = get_next_wizard
    commentable_ids      = @structure.courses.map(&:id)
    commentable_ids << @structure.id
    @comments            = @structure.comments.accepted
    @courses             = @structure.courses
    @places              = @structure.places

    if @structure.premium?
      @medias = @structure.medias.cover_first
    else
      @medias = [@structure.medias.cover_first.first]
    end

    @profile_percentage = 100
    @profile_percentage -= 25 if !@structure.profile_completed?
    @profile_percentage -= 25 if @structure.medias.empty?
    @profile_percentage -= 25 if @comments.empty?
    @profile_percentage -= 25 if @structure.plannings.future.empty?

    @places_latlng = @places.map(&:to_react_json)
  end

  # GET etablissements/:id/quelqu-un-a-deja-le-control
  # When somebody try to register to a structure that already has an admin
  def someone_already_took_control
  end

  # GET member
  def widget
    respond_to do |format|
      format.html
    end
  end

  # GET member
  #   format :json
  # Method called from external sites by the widget
  def widget_ext
    headers['Access-Control-Allow-Origin']  = '*'
    headers['Access-Control-Allow-Methods'] = 'GET, OPTIONS'
    headers['Access-Control-Max-Age']       = '1728000'
    headers['Access-Control-Allow-Headers'] = 'X-Requested-With, X-Prototype-Version, X-CSRF-Token'
    respond_to do |format|
      format.json { render text: render_to_string(partial: 'pro/structures/widget', layout: false) }
    end
  end

  # GET member
  #   format :json
  def wizard
    @wizard = get_next_wizard
    respond_to do |format|
      if @wizard
        format.json { render json: { form: render_to_string(partial: @wizard.partial, layout: false, formats: [:html]), done: false }  }
      else
        format.json { render json: { done: true }  }
      end
    end
  end

  # GET collection
  def stars
    @structures = Structure.order('created_at DESC').where(Structure.arel_table[:comments_count].gteq(5))
  end

  # GET collection
  def index
    @structures = Structure.order('structures.created_at DESC').page(params[:page] || 1).per(50)
    @importer = StructureImporter.new
  end

  # GET member
  def show
    retrieve_home_places
    render action: :edit
  end

  # GET member
  def confirm_email
    render layout: false
  end

  # POST member
  def resend_confirmation_instructions
    @structure.admin.send_confirmation_instructions
    redirect_to edit_pro_structure_path(@structure)
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
    retrieve_home_places
  end

  def edit_order_recipient
    @default_text =  <<-eos
#{@structure.name}
#{@structure.street}
#{@structure.zip_code} #{@structure.city.name}
France
    eos
    render layout: false
  end

  def edit_contact
    @admin            = @structure.admin
    @has_mobile_phone = @structure.phone_numbers.detect { |number| @structure.uses_mobile?(number.number) }.present?
    5.times { @structure.phone_numbers.build }
  end

  def new
    redirect_to new_pro_registration_path, status: 301
  end

  def new_sleeping
    @structure  = Structure.new
    5.times { @structure.places        << @structure.places.publics.build }
    5.times { @structure.phone_numbers << @structure.phone_numbers.build }
  end

  def update
    @admin     = @structure.admin
    if params[:structure] && params[:structure].delete(:delete_logo) == '1'
      @structure.remove_logo!
    end

    if params[:structure] && params[:structure][:subject_descendants_ids].present?
      params[:structure][:subject_ids] = params[:structure][:subject_ids] + params[:structure].delete(:subject_descendants_ids)
    end
    # Update logo if logo_filepicker_url is present
    if params[:structure][:logo_filepicker_url].present?
      @structure.remote_logo_url = params[:structure][:logo_filepicker_url]
    end

    respond_to do |format|
      if @structure.update_attributes(params[:structure])
        format.html { redirect_to (params[:return_to] || edit_pro_structure_path(@structure)), notice: 'Vos informations ont bien été mises à jour.' }
        format.js
      else
        retrieve_home_places
        format.js
        if params[:return_to].present?
          format.html { render action: 'edit_contact' }
        else
          format.html { render action: 'edit' }
        end
      end
    end
  rescue Cloudinary::CarrierWave::UploadError => exception
    respond_to do |format|
      format.html { redirect_to (params[:return_to] || edit_pro_structure_path(@structure)),
                    error: 'Votre ficher est trop large.' }
    end
  end

  def crop_logo
    if !@structure.logo.present?
      redirect_to edit_pro_structure_path(@structure), alert: "Vous n'avez pas de logo"
      return
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

    # Based on name and zipcode, check if structure already exsists
    @structure  = Structure.where( Structure.arel_table[:name].eq(s_name).and(
                                   Structure.arel_table[:zip_code].eq(s_zip_code)) ).first_or_initialize params[:structure]

    if session[:sponsorship_token].present?
      @structure.sponsorship_token = session[:sponsorship_token]
    end

    respond_to do |format|
      # If structure already existed
      if @structure.persisted?
        format.html { redirect_to new_pro_admin_structure_registration_path(@structure, subdomain: 'pro'), notice: 'Félicitations, votre profil est maintenant créé !<br>Dernière étape : créez vos identifiants.' }
      elsif @structure.new_record? && @structure.save
        if current_pro_admin and current_pro_admin.super_admin?
          format.html { redirect_to edit_pro_structure_path(@structure, subdomain: 'pro') }
        else
          format.html { redirect_to new_pro_admin_structure_registration_path(@structure, subdomain: 'pro'), notice: 'Félicitations, votre profil est maintenant créé !<br>Dernière étape : créez vos identifiants.' }
        end
      else
        format.html { render :new_sleeping }
      end
    end
  end

  def update_and_delete
    @structure.update_attributes(params[:structure])
    respond_to do |format|
      format.js
    end
  end

  def destroy
    CrmSync.delay(queue: 'mailers').destroy(@structure.email) if @structure.is_sleeping
    SuperAdminMailer.delay(queue: 'mailers').has_destroyed(@structure)
    AdminMailer.delay(queue: 'mailers').structure_has_been_destroy(@structure)
    if params[:slug_to_associate].present?
      associate_structure = Structure.find(params[:slug_to_associate])
      friendly_id = FriendlyId::Slug.where(slug: @structure.slug, sluggable_type: 'Structure').first_or_create
      friendly_id.update_column :sluggable_id, associate_structure.id
    end
    respond_to do |format|
      if @structure.destroy
        if current_pro_admin.super_admin?
          format.html { redirect_to pro_admins_path, notice: 'Structure supprimé' }
        else
          format.html { redirect_to root_path, notice: 'Vous allez nous manquer...' }
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
  def ask_for_pro_deletion
    if request.xhr?
      render layout: false
    end
  end

  # GET structure/:id/communication
  def communication
  end

  # GET structure/:id/signature
  # Static page that show example of email signature for teachers
  def signature
  end

  # GET structure/:id/logo
  # Static page where teacher can download CoursAvenue logos for their communications
  def logo
  end

  # GET structure/:id/planning-sur-mon-site
  def website_planning
  end

  # GET structure/:id/ask_webmaster_for_planning
  def ask_webmaster_for_planning
    @website_parameter = @structure.website_parameter || @structure.create_website_parameter(slug: @structure.slug)
    @website_parameter.webmaster_email         = params[:email]
    @website_parameter.webmaster_email_sent_at = DateTime.now
    @website_parameter.save
    email_content = '<div class="p">' + params[:text].gsub(/\r\n\r\n/, '</div><div class="p">').gsub(/\r\n/, '<br>') + '</div>'
    AdminMailer.delay(queue: 'mailers').ask_webmaster_for_planning(params[:email], email_content, @structure)
    respond_to do |format|
      format.html { redirect_to website_planning_pro_structure_path(@structure), notice: 'Message envoyé' }
    end
  end

  # POST structure/import
  def import
    file = import_params[:file].tempfile
    importer = StructureImporter.new(file)
    imported_structures = importer.import!

    respond_to do |format|
      if imported_structures.any?
        format.html { redirect_to pro_structures_path,
                      notice: "Le fichier est en cours d'importation." }
      else
        format.html { redirect_to pro_structures_path,
                      error: "Une erreur est survenue lors de l'import du fichier, veuillez rééssayer." }
      end
    end
  end

  def imported_structures
    redirect_to pro_structures_path if params[:structures].nil?

    @structures = params[:structures].map do |id|
      Structure.find(id)
    end
  end

  def enabling_confirmation
    if request.xhr?
      render layout: false
    end
  end

  def enable
    @structure.enable!
    redirect_to pro_structure_path(@structure), notice: 'Profil réactivé avec succès'
  end

  def cards
    @cards = @structure.indexable_cards.includes(:course).with_place.map do |card|
      { id: card.id, name: "#{ card.structure_name } -> #{ card.course_name }" }
    end
    respond_to do |format|
      format.json { render json: { cards: @cards }  }
    end
  end

  # GET structures/duplicates
  def duplicates
    per_page = params[:per_page].present? ? params[:per_page].to_i : 20
    page     = params[:page].present? ? params[:page].to_i : 1
    offset   = (page - 1) * per_page

    @duplicate_lists   = Structure::DuplicateList.includes(:structure).joins(:structure).
      order('structures.created_at DESC').limit(per_page).offset(offset)
    @pagination_scope = OpenStruct.new(
      current_page: page,
      limit_value: per_page,
      total_pages: (Structure::DuplicateList.count / per_page.to_f).ceil
    )
    @last_update = Structure::DuplicateList.pluck(:updated_at).max
  end

  def update_duplicates
    Structure::DuplicateList.delay.save_potential_duplicates
    redirect_to duplicates_pro_structures_path, notice: 'La recherche de doublon est en cours.'
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
    if action_name == 'new' or action_name == 'new_sleeping'
      'home'
    elsif action_name == 'create' || action_name == 'someone_already_took_control'
      'admin_pages'
    else
      'admin'
    end
  end

  def retrieve_home_places
    if @structure.places.homes.empty?
      @structure.places.homes.build
    end
    @home_places = @structure.places.includes(:city).select{ |p| p.type == 'Place::Home' }
    if @home_places.empty?
      @home_places << @structure.places.homes.build
    end
  end

  # Get the selectable Facebook pages
  #
  # This method adds the structure's facebook_url if it is not part of the
  # pages managed by the admin.
  #
  # @return an Array of Array of [page_name, URL]
  def retrieve_facebook_pages
    @admin ||= @structure.admin
    return @facebook_pages = [] if @admin.nil?
    if @admin.from_facebook?
      pages = @admin.facebook_pages

      if @structure.facebook_url? and !pages.map(&:second).include?(@structure.facebook_url)
        pages << ['Autre', @structure.facebook_url] unless pages.empty?
      else
        pages << ['Autre', 'other']
      end

      @facebook_pages = pages
    else
      @facebook_pages = []
    end
  end

  def load_structure
    if params[:id] == '_REPLACE_THIS_' and current_pro_admin
      params[:id] = current_pro_admin.structure.slug
    end
    @structure = Structure.friendly.find(params[:id]) if params[:id].present?
  end

  def import_params
    params.require(:structure_import).permit(:file)
  end
end
