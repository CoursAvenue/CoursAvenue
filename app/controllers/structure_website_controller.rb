class StructureWebsiteController < ApplicationController

  layout 'structure_websites/website'

  before_action :load_structure

  private

  def load_structure
    @structure = Structure.find request.subdomain
    if !@structure.premium?
      redirect_to root_url(subdomain: 'www'), notice: "Cette page n'existe pas"
    end
  end

end
