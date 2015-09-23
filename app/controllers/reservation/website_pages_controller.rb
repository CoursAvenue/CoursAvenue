# encoding: utf-8
class Reservation::WebsitePagesController < ReservationController
  def show
    @page = @structure.website_pages.order('created_at DESC').friendly.find(params[:id])
  end
end
