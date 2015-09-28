class Pro::RegistrationsController < Pro::PublicController
  helper StructuresHelper
  layout 'home'

  def new
    if current_pro_admin.present? and current_pro_admin.structure.present? and
        !current_pro_admin.super_admin?
      redirect_to pro_structure_path(current_pro_admin.structure)
      return
    end
    @registration_form = Structure::RegistrationForm.new
  end

  def create
    @form = Structure::RegistrationForm.new(params[:structure_registration_form])

    if (admin = @form.existing_admin?) and admin.valid_password?(@form.admin_password)
      sign_in admin
      redirect_to pro_structure_path(admin.structure), notice: 'Vous avez été connecté avec succés.'
      return
    end

    if @form.save
      sign_in @form.admin
      redirect_to new_course_pro_registrations_path(
        id: @form.structure.slug, course_type: @form.course_type
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
    @course_creation_form = Structure::CourseCreationForm.new(
      params[:structure_course_creation_form]
    )
    @course_creation_form.set_dates_and_times(params[:structure_course_creation_form])

    @structure = Structure.find(params[:structure_course_creation_form][:structure_id])
    @course_partial = @course_creation_form.course_type.split('::').last.downcase

    if @course_creation_form.save
      redirect_to edit_pro_structure_path(@structure),
        notice: 'Activité créé avec succés.'
    else
      render :new_course
    end
  end
end
