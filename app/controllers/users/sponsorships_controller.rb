class Users::SponsorshipsController < Pro::ProController

  layout 'user_profile'

  before_action :authenticate_user!
  load_and_authorize_resource :user

  # GET eleves/:user_id/parrainages
  def index
    @sponsorships = @user.sponsorships
  end

  # GET eleves/:user_id/parrainaged/new
  def new
    # @discount = @user.discount
    @discount = 0
  end

  protected

  def layout_locals
    { hide_menu: true }
  end
end
