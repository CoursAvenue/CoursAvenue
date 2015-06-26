class Pro::HomeController < Pro::ProController

  layout :get_layout

  def mailjet_custo
  end

  def portraits
  end

  def features
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
    @monthly_plans = Subscriptions::Plan.monthly.decorate
    @yearly_plans  = Subscriptions::Plan.yearly.decorate
    @structure     = current_pro_admin.structure if current_pro_admin
    @email = ::Email.new
  end

  def convictions
    redirect_to pro_pages_why_be_recommended_url(subdomain: 'pro'), status: 301
  end

  def questions
    @sections = ::Faq::Section.pro

    render template: 'pages/faq_users'
  end

  private

  def get_layout
    if action_name == 'index' or
       action_name == 'features' or
       action_name == 'price'
      'home'
    else
      'admin_pages'
    end
  end
end
