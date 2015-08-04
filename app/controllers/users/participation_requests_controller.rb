class Users::ParticipationRequestsController < ApplicationController

  layout 'user_profile'

  before_action :authenticate_user!
  load_and_authorize_resource :user

  # GET eleves/:user_id/participation_request/
  def index
    @past_participation_requests    = (@user.participation_requests.canceled + @user.participation_requests.past).uniq.sort_by(&:date).reverse
    @current_participation_requests = (@user.participation_requests.upcoming.accepted + @user.participation_requests.upcoming.pending).sort_by(&:date)
  end

  # GET eleves/:user_id/participation_request/:id
  def show
    @participation_request = @user.participation_requests.find(params[:id]).decorate
    @structure             = @participation_request.structure
  end

  protected

  def layout_locals
    { hide_menu: true }
  end
end
