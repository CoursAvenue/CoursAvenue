# encoding: utf-8
class ::Pro::Structures::InvitedTeachersController < Pro::ProController
  before_action :authenticate_pro_admin!
  load_and_authorize_resource :structure

  def index
    @structure        = Structure.friendly.find params[:structure_id]
    @invited_teachers = @structure.invited_teachers
  end
end
