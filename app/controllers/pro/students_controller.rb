# encoding: utf-8
class Pro::StudentsController < Pro::ProController
  before_filter :authenticate_pro_admin!

  layout 'admin'

  authorize_resource :student

  def index
    @students = Student.order('created_at DESC').limit(500)
  end
end
