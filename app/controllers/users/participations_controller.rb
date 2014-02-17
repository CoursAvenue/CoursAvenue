class Users::ParticipationsController < ApplicationController
  # For an example of a conversation controller see:
  # https://github.com/ging/social_stream/blob/master/base/app/controllers/conversations_controller.rb
  before_action :authenticate_user!

  layout 'user_profile'

  def index
    @participations = current_user.participations
  end

  def destroy
    @participations = current_user.participations.find params[:id]
    respond_to do |format|
      if @participations.destroy
        format.html { redirect_to user_participations_path(current_user), notice: 'Vous avez bien été desinscrit' }
      else
        format.html { redirect_to user_participations_path(current_user), notice: "Une erreur s'est produite" }
      end
    end
  end
end
