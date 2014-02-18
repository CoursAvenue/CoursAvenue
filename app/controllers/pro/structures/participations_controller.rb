# encoding: utf-8
class Pro::Structures::ParticipationsController < Pro::ProController
  before_action :authenticate_pro_admin!
  before_action :load_structure

  layout 'admin'

  load_and_authorize_resource :structure

  def index
    @open_courses = @structure.courses.open_courses
  end

  private

  def load_structure
    @structure = Structure.find(params[:structure_id])
  end
end
