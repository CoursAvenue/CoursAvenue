# encoding: utf-8
class Pro::Structures::CoursesController < Pro::ProController
  layout 'admin'

  before_action :authenticate_pro_admin!, except: [:index]
  before_action :load_structure

  load_and_authorize_resource :structure, find_by: :slug, except: [:index]

  def new
    @course = @structure.courses.build(type: params[:type])
    if request.xhr?
      render partial: 'form', layout: false
    else
      redirect_to pro_structure_courses_path(@structure, type: params[:type], anchor: 'course')
    end
  end

  # PATCH member
  # @params { course: { media: 'filepickerurl' } }
  def add_image
    @course = @structure.courses.friendly.find params[:id]
    begin
      media_image = Media::Image.create filepicker_url: params[:course][:media], remote_image_url: params[:course][:media], mediable: @structure
    rescue Cloudinary::CarrierWave::UploadError => exception
      # TODO: Check after Rails update.
      # For some reason, the regular `redirect_to ..., error: '...'` doesn't seem to work here.
      # So we manually set the error flash message.
      flash[:error] = 'La taille de votre fichier est trop grande, veuillez la réduire et rééssayer.'
      redirect_to pro_structure_courses_path(@structure)
    else
      @course.media = media_image
      @course.save
      redirect_to pro_structure_courses_path(@structure), notice: 'Le cours a bien été mis à jour'
    end
  end

  def choose_media
    @course = @structure.courses.friendly.find params[:id]
    if request.xhr?
      render layout: false
    end
  end

  def index
    # So...
    # Nico sent this email: "Nouveau : envoyez votre planning à tous vos contacts"
    # The sent to: https://pro.coursavenue.com/etablissements/soraya-saadi-association-feminissime-orient/cours
    # So we have to redirect the user to HIS structure
    authenticate_pro_admin! if !current_pro_admin
    if current_pro_admin and !current_pro_admin.super_admin
      @structure = current_pro_admin.structure
    else
      @structure = Structure.find(params[:structure_id])
    end
    if @structure.slug != params[:structure_id]
      redirect_to pro_structure_courses_path(@structure)
      return
    end

    @trainings = @structure.courses.trainings.order('name ASC').includes(:media, :indexable_cards, :prices)
    @lessons   = @structure.courses.lessons.order('name ASC').includes(:media, :indexable_cards, plannings: [:place])
    @privates  = @structure.courses.privates.order('name ASC').includes(:media, :indexable_cards, :place)
  end

  def regular
    redirect_to pro_structure_courses_path(@structure)
  end

  def trainings
    redirect_to pro_structure_courses_path(@structure)
  end

  def configure_openings
    @courses = @structure.courses.regulars.order('name ASC')
    if request.xhr?
      render layout: false
    end
  end

  def update_openings
    courses_openings[:courses].each do |index, course_param|
      course            = @structure.courses.find(course_param[:id])
      if (course_param[:has_vacation] == 'on')
        course.start_date = Time.at(course_param[:start_date_unix].to_i).to_date
      else
        course.start_date = Date.parse('01 july 2015')
      end
      course.end_date   = Time.at(course_param[:end_date_unix].to_i).to_date
      course.save
    end
    redirect_to pro_structure_courses_path(@structure), notice: 'Vos dates de fermetures ont été mises à jour'
  end

  def edit
    @course = @structure.courses.friendly.find params[:id]
    if request.xhr?
      render partial: 'form', layout: false
    else
      redirect_to pro_structure_courses_path(@course.structure)
    end
  end

  def ask_for_deletion
    @course = Course.friendly.find params[:id]
    if request.xhr?
      render layout: false
    end
  end

  def create
    @course           = Course.new course_attributes
    @course.structure = @structure
    respond_to do |format|
      if @course.save
        format.html { redirect_to pro_structure_course_prices_path(@structure, @course), notice: 'Vous pouvez maintenant définir les tarifs pour ce cours' }
        format.js
      else
        format.html { render action: :new}
        format.js
      end
    end
  end

  def update
    @course = @structure.courses.friendly.find params[:id]
    if params[:course][:delete_place_id]
      @course.place = nil
    end
    respond_to do |format|
      if @course.update_attributes course_attributes
        format.html { redirect_to pro_structure_courses_path(@structure), notice: 'Le cours a bien été mis à jour' }
        format.json { render json: {}, status: 200 }
        format.js
      else
        format.html { render action: :new }
        format.json { render json: {}, status: 500 }
        format.js
      end
    end
  end

  def destroy
    @course = Course.friendly.find params[:id]
    respond_to do |format|
      if @course.destroy
        format.html { redirect_to pro_structure_courses_path(@structure), notice: "Le cours a bien été supprimé" }
        format.js
      else
        format.html { redirect_to pro_structure_courses_path(@structure), alert: "Une erreur s'est produite" }
        format.js
      end
    end
  end

  def generate_cards
    @structure.courses.each do |course|
      IndexableCard.delay(queue: 'cards', priority: 10).create_from_course(course)
    end

    redirect_to pro_structure_courses_path(@structure),
      notice: 'Les résultats sont dans la queue de mise a jour'
  end

  private

  def load_structure
    @structure = Structure.friendly.find(params[:structure_id])
  end

  def courses_openings
    params.permit(courses: [:id, :start_date, :end_date, :start_date_unix, :end_date_unix, :has_vacation])
  end

  def course_attributes
    params.require(:course).permit(:type, :name, :frequency, :description, :teaches_at_home,
                                   :cant_be_joined_during_year, :no_class_during_holidays,
                                   :place_id, :on_appointment, :max_age_for_kid, :min_age_for_kid,
                                   :accepts_payment, :media_id, :no_trial,
                                   :accepts_payment, :price_group_id,
                                   audience_ids: [], level_ids: [], subject_ids: [],
                                   prices_attributes: [:id, :number, :type, :amount, :promo_amount, :info])
  end

end
