class Users::SponsorshipsController < Pro::ProController
  before_action :authenticate_user!
  load_and_authorize_resource :user, find_by: :slug

  layout 'user_profile'

  # GET eleves/:user_id/pass-decouverte/parrainages
  def index
    @sponsorships = @user.sponsorships
  end
end
