class Users::ParticipationsController < ApplicationController
  # For an example of a conversation controller see:
  # https://github.com/ging/social_stream/blob/master/base/app/controllers/conversations_controller.rb
  before_action :authenticate_user!

  layout 'user_profile'

  def index
    @participations = current_user.participations
  end
end
