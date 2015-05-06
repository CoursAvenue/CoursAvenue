class WebsiteParameterDecorator < Draper::Decorator
  delegate_all

  def website_url
    h.structure_website_presentation_url(subdomain: slug)
  end

end
