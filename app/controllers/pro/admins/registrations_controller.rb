# encoding: utf-8
class Pro::Admins::RegistrationsController < Devise::RegistrationsController
  layout 'admin_pages'

  def new
    @structure = Structure.where(slug: params[:structure_id]).first
    if @structure
      @admin     = @structure.admins.build(email: @structure.contact_email)
    else
      redirect_to inscription_pro_structures_path
    end
  end

  def create
    @admin     = Admin.new params[:admin]
    @structure = @admin.structure
    respond_to do |format|
      if @admin.save
        AdminMailer.delay.new_admin_has_signed_up(@admin)
        format.html { redirect_to waiting_for_activation_pro_admins_path, notice: 'Un email de confirmation vient de vous être envoyé' }
      else
        format.html { render 'new'}
      end
    end
  end
end
