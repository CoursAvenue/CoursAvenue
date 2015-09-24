# encoding: utf-8
class Pro::Admins::RegistrationsController < Devise::RegistrationsController
  layout 'admin_pages'

  def new
    @structure = Structure.where(slug: params[:structure_id]).first
    if @structure
      # TODO: fix this, when creating a structure, it is sleeping and if we remove
      # `@structure.created_at < 1.day.ago` it will be redirected to take_control page!
      if @structure.is_sleeping? and @structure.created_at < 1.day.ago
        @admin = Admin.new(structure: @structure)
        render template: 'pro/admins/registrations/take_control'
      else
        @admin = Admin.new(structure: @structure, email: @structure.contact_email)
        render
      end
    else
      redirect_to inscription_pro_structures_path
    end
  end

  def create
    @structure = Structure.friendly.find params[:admin].delete(:structure_id)

    if !@structure.admin
      @admin = Admin.new params[:admin]
      @admin.structure = @structure
    end
    respond_to do |format|
      if @structure.admin.persisted?
        SuperAdminMailer.delay(queue: 'mailers').someone_tried_to_take_control_of_existing_structure(@structure, params[:admin][:email])
        format.html { redirect_to someone_already_took_control_pro_structure_path(@structure) }
      elsif (@admin and @admin.save)
        sign_in @admin
        SuperAdminMailer.delay(queue: 'mailers').new_admin_has_signed_up(@admin)
        format.html { redirect_to edit_pro_structure_path(@structure), notice: 'Bienvenue !' }
      else
        format.html { render 'new' }
      end
    end
  end
end
