class Pro::HomeController < Pro::ProController
  layout 'admin_pages'

  def mailjet_custo
  end

  def index
    @admin      = ::Admin.new
  end

  def white_book
  end

  def presentation
  end

  def widget
    @structures = Structure.where { widget_status == 'installed' }.limit(100)
  end

  def price
    @email = ::Email.new
  end

  def press
  end

  def jpo
  end

  def convictions
    redirect_to pro_pages_why_be_recommended_url(subdomain: 'pro'), status: 301
  end
end
