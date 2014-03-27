class Users::ParticipationsController < ApplicationController
  before_action :authenticate_user!

  layout 'user_profile'
  load_and_authorize_resource :user, find_by: :slug

  # GET
  def index
    @participations = @user.participations.not_canceled.order('created_at DESC')
    if @participations.any?
      @participation = @participations.first
      @structure     = @participation.structure
    end
  end

  def destroy
    @participation = @user.participations.find params[:id]
    respond_to do |format|
      if @participation.cancel!
        format.html { redirect_to user_participations_path(@user), notice: 'Vous avez bien été desinscrit' }
      else
        format.html { redirect_to user_participations_path(@user), notice: "Une erreur s'est produite" }
      end
    end
  end
end
