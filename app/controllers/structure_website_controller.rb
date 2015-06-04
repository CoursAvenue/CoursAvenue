class StructureWebsiteController < ApplicationController

  layout 'structure_websites/website'

  before_action :redirect_if_subdomain

  private

  def redirect_if_subdomain
    if request.subdomain != 'www'
      redirect_to structure_website_structure_url(request.subdomain, subdomain: 'www')
      return
    end
  end

end
