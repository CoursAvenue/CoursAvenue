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

  def widget
    @structures = Structure.where( Structure.arel_table[:widget_status].eq('installed').and(
                                   Structure.arel_table[:widget_url].not_eq('')).and(
                                   Structure.arel_table[:widget_url].not_eq(nil)) ).limit(60)
  end

  def price
    @email = ::Email.new
  end

  def jpo
    redirect_to root_url(subdomain: CoursAvenue::Application::PRO_SUBDOMAIN), status: 301
  end

  def july_offer
    redirect_to root_url(subdomain: CoursAvenue::Application::PRO_SUBDOMAIN, notice: "L'offre spécial été n'est plus valable"), status: 301
  end

  def convictions
    redirect_to pro_pages_why_be_recommended_url(subdomain: CoursAvenue::Application::PRO_SUBDOMAIN), status: 301
  end

  def questions
    @sections = ::Faq::Section.pro

    render template: 'pages/faq_users'
  end
end
