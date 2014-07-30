class Pro::HomeController < Pro::ProController
  layout 'admin_pages'

  def mailjet_custo
  end

  def portraits
  end

  def index
    @admin      = ::Admin.new
  end

  def white_book
  end

  def presentation
  end

  def widget
    @structures = Structure.where( Structure.arel_table[:widget_status].eq('installed').and(
                                   Structure.arel_table[:widget_url].not_eq('')).and(
                                   Structure.arel_table[:widget_url].not_eq(nil)) ).limit(100)
  end

  def price
    @email = ::Email.new
  end

  def press
  end

  def jpo
  end

  def july_offer
  end

  def convictions
    redirect_to pro_pages_why_be_recommended_url(subdomain: CoursAvenue::Application::PRO_SUBDOMAIN), status: 301
  end
end
