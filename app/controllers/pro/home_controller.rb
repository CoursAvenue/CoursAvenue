class Pro::HomeController < Pro::ProController
  layout 'admin_pages'

  def index
    @admin      = ::Admin.new
  end

  def presentation
  end

  def price
    @email = ::Email.new
  end

  def press
  end
end
