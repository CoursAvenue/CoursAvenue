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

  #
  # def step_zero
  # end
  #
  # def step_one
  #   if request.xhr?
  #     render layout: false
  #   else
  #     raise 'step_one'
  #   end
  # end
  #
  # def step_two
  #   if request.xhr?
  #     render layout: false
  #   else
  #     raise 'step_two'
  #   end
  # end
  #
  # def step_three
  #   if request.xhr?
  #     render layout: false
  #   else
  #     raise 'step_three'
  #   end
  # end
  #
  # def step_four
  #   if request.xhr?
  #     render layout: false
  #   else
  #     raise 'step_four'
  #   end
  # end
end
