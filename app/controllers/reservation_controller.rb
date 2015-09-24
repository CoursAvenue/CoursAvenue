class ReservationController < ApplicationController

  layout 'reservations/website'

  before_action :redirect_if_subdomain

  private

  def redirect_if_subdomain
    if request.subdomain != 'www'
      redirect_to reservation_structure_url(request.subdomain, subdomain: 'www')
      return
    end
  end

end
