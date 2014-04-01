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

  def add_invited_friends
    @participation = @user.participations.find params[:id]
    if request.xhr?
      render partial: 'add_invited_friends', layout: false
    end
  end

  def update
    @participation = @user.participations.find params[:id]
    @participation.build_invited_friends(params[:participation][:invited_friends][:email])
    @participation.save
    respond_to do |format|
      format.html { redirect_to user_participations_path(@user), notice: 'Les infos ont bien été mise à jour' }
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
