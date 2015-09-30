class Pro::Admins::OnboardingController < Pro::Public
  before_action :render_step, except: [:update]

  private

  def render_step
    @structure = Structure.find(params[:id]) if params[:id].present?
    if request.xhr?
      render layout: false
    end
  end
end
