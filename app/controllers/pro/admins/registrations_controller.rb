class Pro::Admins::RegistrationsController < Devise::RegistrationsController
  layout 'admin_pages'

  def new
    if params[:structure]
      @structure = Structure.find params[:structure]
    else
      @structure = Structure.new
    end
    @admin = Admin.new
  end

  def create
    @admin = Admin.new params[:admin]
    respond_to do |format|
      if @admin.save
        la
        sign_in @admin
        format.html { redirect_to pro_structure_path(@admin.structure), :notice => t('admin.registration.successful') }
      else
        format.html { render 'new'}
      end
    end
  end
end
