class Admin::AdminsController < Admin::AdminController
  def index
    @admins = Admin.order('created_at DESC').page(params[:page])
    respond_to do |format|
      format.html
    end
  end

  def edit
    @admin     = ::Admin.find(params[:id])
    @structure = @admin.structure
    if @structure.nil?
      redirect_to (request.referrer || root_path), alert: "Pas d'admin pour cet établissement"
    end
  end

  def update
    @admin = ::Admin.find(params[:id])

    if !@admin.new_record? && params[:admin][:password].blank?
      params[:admin].delete :password
      params[:admin].delete :password_confirmation
    end
    @structure = @admin.structure
    respond_to do |format|
      if @admin.update_attributes(params[:admin])
        format.html { redirect_to admin_admins_path, notice: "L'admin a été mis a jour avec succés." }
        format.js { render nothing: true }
      else
        format.html { render action: :edit }
      end
    end
  end

  def confirm
    @admin = ::Admin.find(params[:id])
    respond_to do |format|
      if @admin.confirm!
        format.html { redirect_to pro_admins_path }
      else
        format.html { redirect_to pro_admins_path, error: 'Admin could not have been confirmed.' }
      end
    end
  end
end
