class Pro::HomeController < Pro::ProController
  layout 'admin_pages'

  def index
    @admin      = ::Admin.new
    @structures = Structure.where{image_updated_at != nil}.order('comments_count DESC').limit(8)
  end

  def presentation
  end

  def price
    @admin = ::Admin.new
  end

  def press
  end
end
