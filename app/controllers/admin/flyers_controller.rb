class Admin::FlyersController < Admin::AdminController

  def index
    @flyers = Flyer.all
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
