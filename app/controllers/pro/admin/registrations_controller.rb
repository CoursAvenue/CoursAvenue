class Pro::Admin::RegistrationsController < Devise::RegistrationsController
  layout 'admin_pages'

  def new
    @structure = Structure.new
    super
  end

  def create
    # TODO
    # Begin transaction ?
    @admin           = Admin.new params[:admin]
    @structure       = Structure.new(params[:structure])
    @admin.structure = @structure
    respond_to do |format|
      if @admin.valid? and @admin.structure.valid?
        @admin.save
        if params[:i_am_teacher]
          teacher = Teacher.new(name: @admin.full_name)
          teacher.structure = @admin.structure
          teacher.save
        end
        sign_in @admin
        # format.html {redirect_to edit_structure_path(@admin.structure, anchor: 'description-textarea'), :notice => t("admin.registration.successful")}
        format.html {redirect_to structure_teachers_path(@admin.structure), :notice => t("admin.registration.successful")}
      else
        format.html {render 'new'}
      end
    end
  end
end
