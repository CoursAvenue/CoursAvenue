class Pro::ProController < ApplicationController
  helper OnboardingHelper
  layout 'admin'

  before_action :authenticate_pro_admin!
end
