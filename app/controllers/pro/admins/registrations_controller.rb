# encoding: utf-8
class Pro::Admins::RegistrationsController < Devise::RegistrationsController
  layout 'admin_pages'

  def new
    @structure = Structure.where(slug: params[:structure_id]).first
    if @structure
      # TODO: fix this, when creating a structure, it is sleeping and if we remove
      # `@structure.created_at < 1.day.ago` it will be redirected to take_control page!
      if @structure.is_sleeping? and @structure.created_at < 1.day.ago
        @admin = @structure.admins.build
        render template: 'pro/admins/registrations/take_control'
      else
        @admin = @structure.admins.build(email: @structure.contact_email)
        render
      end
    else
      redirect_to inscription_pro_structures_path
    end
  end

  def create
    @structure = Structure.friendly.find params[:admin][:structure_id]

    # Duplicate structure in case an admin takes control of a structure and afterwards
    # we want to rollback
    @structure.delay.duplicate_structure

    if @structure.admins.length == 0
      @admin     = Admin.new params[:admin]
    end
    respond_to do |format|
      if @structure.admins.length > 0
        SuperAdminMailer.delay.someone_tried_to_take_control_of_existing_structure(@structure, params[:admin][:email])
        format.html { redirect_to someone_already_took_control_pro_structure_path(@structure) }
      elsif @admin.save
        @structure.delay.index
        @admin.send_confirmation_instructions
        SuperAdminMailer.delay.new_admin_has_signed_up(@admin)
        format.html { redirect_to waiting_for_activation_pro_admins_path(email: @admin.unconfirmed_email), notice: 'Un email de confirmation vient de vous être envoyé' }
      else
        format.html { render 'new' }
      end
    end
  end
end
