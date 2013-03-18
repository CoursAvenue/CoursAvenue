class Pro::HomeController < Pro::ProController
  layout 'admin_pages'

  def index
    @admin = ::Admin.new
  end

  def presentation
  end
end
