# encoding: utf-8
class ::Pro::InvitedTeachersController < Pro::ProController
  before_action :authenticate_pro_admin!
  load_and_authorize_resource :invited_teacher

  def index
    @invited_teachers = InvitedTeacher.order('created_at DESC')
  end

end
