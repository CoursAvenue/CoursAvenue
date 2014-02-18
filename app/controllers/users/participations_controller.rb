class Users::ParticipationsController < ApplicationController
  before_action :authenticate_user!

  layout 'user_profile'

  def index
    @participations = current_user.participations.not_canceled
  end

  def destroy
    @participation = current_user.participations.find params[:id]
    respond_to do |format|
      if @participation.cancel!
        format.html { redirect_to user_participations_path(current_user), notice: 'Vous avez bien été desinscrit' }
      else
        format.html { redirect_to user_participations_path(current_user), notice: "Une erreur s'est produite" }
      end
    end
  end
end
