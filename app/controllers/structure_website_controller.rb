class StructureWebsiteController < ApplicationController

  layout 'structure_website'

  before_action :load_structure

  private

  def load_structure
    @structure = Structure.find request.subdomain
  end

end
