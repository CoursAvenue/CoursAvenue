class Pro::Admin::RegistrationsController < Devise::RegistrationsController
  layout 'admin_pages'

  def new
    @structure = Structure.new
    super
  end

  def create
    # Begin transaction ?
    @admin           = Admin.new params[:admin_user]
    @admin.structure = Structure.new(params[:structure])
    respond_to do |format|
      if @admin.valid? and @admin.structure.valid?
        @admin.save
        format.html {redirect_to structure_path(@admin.structure), :notice => t("notices.successfully_done")}
        format.js
      else
        format.html {render 'new'}
      end
    end
  end
end
