# encoding: utf-8
class Pro::OpenCoursesController < Pro::ProController
  before_action :authenticate_pro_super_admin!
  layout 'admin'

  def index
    @courses = Course::Open.all
  end
end
