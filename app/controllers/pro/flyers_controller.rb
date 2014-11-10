class Pro::FlyersController < Pro::ProController
  before_action :authenticate_pro_super_admin!
  layout 'admin'

  def index
    @flyers = Flyer.all
  end

  def show
    @flyer = Flyer.find params[:id]
    render layout: false
  end
end
