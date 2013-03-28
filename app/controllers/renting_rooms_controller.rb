class RentingRoomsController < InheritedResources::Base
  actions :create

  def create
    create! do |success, failure|
      success.html do
        flash[:notice] = "Merci pour votre soumission"
        redirect_to pages_rent_places_path
      end
      failure.html { render template: 'pages/rent_places'}
    end
  end
end
