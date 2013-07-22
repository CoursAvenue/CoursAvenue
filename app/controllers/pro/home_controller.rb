class Pro::HomeController < Pro::ProController
  layout 'admin_pages'

  def index
    @admin      = ::Admin.new
    @structures = Structure.where{(image_updated_at != nil) & (comments_count != nil)}.order('comments_count DESC').limit(8)
    unless params[:ab]
      @places     = PlaceSearch.search lat: 48.8540, lng: 2.3417, radius: 9, per_page: 1000
      @json_place_addresses = @places.to_gmaps4rails
    end
  end

  def presentation
  end

  def price
    @admin = ::Admin.new
  end

  def press
  end
end
