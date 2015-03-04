class Pro::Structures::NewslettersController < ApplicationController
  before_action :authenticate_pro_admin!
  before_action :set_structure

  layout 'admin'

  def index
    @newsletters = @structure.newsletters
  end

  def new
    @layouts = Newsletter::Layout.all.as_json.map do |layout|
      layout["attributes"]
    end
  end

  private

  def set_structure
    # @structure = Structure.includes(:newsletters).find(params[:structure_id])
    @structure = Structure.find(params[:structure_id])
  end
end
