class Pro::Admin::RegistrationsController < Devise::RegistrationsController
  layout 'admin_pages'

  def new
    @structure = Structure.new
    super
  end

  def create
    # TODO
    # Begin transaction ?
    @admin           = Admin.new params[:admin_user]
    @admin.structure = Structure.new(params[:structure])
    respond_to do |format|
      if @admin.valid? and @admin.structure.valid?
        @admin.save
        if params[:i_am_teacher]
          teacher = Teacher.new(name: @admin.full_name)
          teacher.structure = @admin.structure
        end
        format.html {redirect_to structure_path(@admin.structure), :notice => t("notices.successfully_done")}
        format.js
      else
        format.html {render 'new'}
      end
    end
  end
end
