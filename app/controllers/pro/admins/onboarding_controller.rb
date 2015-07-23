class Pro::Admins::OnboardingController < ApplicationController
  before_action :render_step

  private

  def render_step
    if request.xhr?
      render layout: false
    else
      raise 'step_one'
    end
  end
end
