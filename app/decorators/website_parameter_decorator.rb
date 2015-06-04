class WebsiteParameterDecorator < Draper::Decorator
  delegate_all

  def website_url
    object.website || h.structure_url(object, subdomain: 'www')
  end

end
