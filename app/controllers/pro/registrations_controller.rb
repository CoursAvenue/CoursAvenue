class Pro::RegistrationsController < Pro::ProController
  layout 'home'

  def new
    @registration_form = Structure::RegistrationForm.new
  end

  def create
    @registration_form = Structure::RegistrationForm.new(registration_params)

    if @registration_form.save
      redirect_to new_course_pro_registrations_path(
        id: @registration_form.structure.slug, course_type: @registration_form.course_type
      ), notice: 'Établissement créé avec succés'
    else
      render :new
    end
  end

  def new_course
    @structure   = Structure.find(params[:id])
    @course_type = params[:course_type]
    @course      = @structure.courses.new
  end

  def create_course
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
end
