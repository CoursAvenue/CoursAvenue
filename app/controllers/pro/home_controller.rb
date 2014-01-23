class Pro::HomeController < Pro::ProController
  layout 'admin_pages'

  def index
    @admin      = ::Admin.new
  end

  def presentation
  end

  def widget
    @structures = Structure.where{widget_status == 'installed'}.limit(100)
  end

  def price
    @email = ::Email.new
  end

  def press
  end

  def jpo
  end
end
