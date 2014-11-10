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

  def update
    @flyer = Flyer.find params[:id]

    respond_to do |format|
      if @flyer.update_attributes params[:flyer]
        format.js { render nothing: true }
      else
        format.js { render nothing: true }
      end
    end
  end
end
