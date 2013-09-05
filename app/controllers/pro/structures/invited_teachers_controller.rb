# encoding: utf-8
class ::Pro::Structures::InvitedTeachersController < Pro::ProController
  before_filter :authenticate_pro_admin!
  load_and_authorize_resource :structure

  def index
    @structure        = Structure.find params[:structure_id]
    @invited_teachers = @structure.invited_teachers
  end
end
