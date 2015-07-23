class Pro::Admins::OnboardingController < ApplicationController
  before_action :render_step, except: [:update]

  def update
    @structure = Structure.find(params[:id])
    @admin = @structure.main_contact
    raise 'update'

    @admin.onboard! if @admin
    redirect_to edit_pro_structure_path(@structure)
  end

  private

  def render_step
    @structure = Structure.find(params[:id]) if params[:id].present?
    if request.xhr?
      render layout: false
    end
  end
end
