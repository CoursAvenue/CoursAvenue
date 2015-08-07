class Pro::RegistrationsController < Pro::ProController
  helper StructuresHelper
  layout 'home'

  def new
    @registration_form = Structure::RegistrationForm.new
  end

  def create
    @registration_form = Structure::RegistrationForm.new(registration_params)

    if @registration_form.save
      sign_in @registration_form.admin
      redirect_to new_course_pro_registrations_path(
        id: @registration_form.structure.slug, course_type: @registration_form.course_type
      ), notice: 'Publiez maintenant votre 1ère activité'
    else
      render :new
    end
  end

  def new_course
    @structure   = Structure.includes(:subjects).find(params[:id])
    @course_partial = params[:course_type]
    @course_creation_form = Structure::CourseCreationForm.new(structure_id: params[:id])
  end

  def create_course
    @course_creation_form = Structure::CourseCreationForm.new(course_params)
    @course_creation_form.set_dates_and_times(params[:structure_course_creation_form])

    @structure = Structure.find(course_params[:structure_id])
    @course_partial = @course_creation_form.course_type.split('::').last.downcase

    if @course_creation_form.save
      redirect_to edit_pro_structure_path(@structure),
        notice: 'Activité créé avec succés.'
    else
      render :new_course
    end
  end

  private

  def registration_params
    params.require(:structure_registration_form).permit(
      :structure_name,
      :admin_email,
      :admin_password,

      :course_type,

      structure_subjects_ids: [],
      structure_subject_descendants_ids: []
    )
  end

  def course_params
    params.require(:structure_course_creation_form).permit(
      :structure_id,

      :course_type,
      :course_name,
      :course_description,
      :course_frequency,
      :course_cant_be_joined_during_year,
      :course_no_class_during_holidays,

      :place_name,
      :place_street,
      :place_zip_code,
      :place_city_id,
      :place_latitude,
      :place_longitude,

      :place_home_zip_code,
      :place_home_city_id,
      :place_home_radius,

      :teaches_at_home,
      :teaches_at_place,

      :planning_week_day,
      :planning_start_date,
      :planning_end_date,

      course_subject_ids: [],
      course_prices_attributes: [:type, :number, :amount, :info],

      audience_ids: [],
      level_ids: [],
    )
  end
end
