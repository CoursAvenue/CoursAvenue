# encoding: utf-8
class Pro::SponsorshipsController < Pro::ProController
  before_action :authenticate_pro_super_admin!

  def index
    @sponsorships = Sponsorship.all
    @sponsorships = Kaminari.paginate_array(@sponsorships).page(params[:page] || 1).per(20)
  end
end
