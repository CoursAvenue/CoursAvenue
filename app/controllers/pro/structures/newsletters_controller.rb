class Pro::Structures::NewslettersController < ApplicationController
  before_action :authenticate_pro_admin!
  before_action :set_structure

  layout 'admin'

  def index
    # @newsletters = @structure.newsletters
  end

  private

  def set_structure
    # @structure = Structure.includes(:newsletters).find(params[:structure_id])
    @structure = Structure.find(params[:structure_id])
  end
end
