# encoding: utf-8
class Pro::DiscoveryPassesController < Pro::ProController
  before_action :authenticate_pro_super_admin!

  def index
    @discovery_passes = DiscoveryPass.active.all
    @discovery_passes = Kaminari.paginate_array(@discovery_passes).page(params[:page] || 1).per(20)
  end
end
