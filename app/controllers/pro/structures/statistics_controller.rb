# encoding: utf-8
class Pro::Structures::StatisticsController < InheritedResources::Base
  before_action :authenticate_pro_admin!
  load_and_authorize_resource :structure

  layout 'admin'

  def index
    @structure = Structure.find params[:structure_id]
    @statistics = @structure.statistics
  end
end
