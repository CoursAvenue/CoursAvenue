class StructureWebsiteController < ApplicationController

  layout 'structure_websites/website'

  before_action :load_structure

  private

  def load_structure
    @structure = Structure.find request.subdomain
  end

end
