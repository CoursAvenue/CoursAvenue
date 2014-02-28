# encoding: utf-8
class Pro::OpenCoursesController < Pro::ProController
  before_action :authenticate_pro_super_admin!
  layout 'admin'

  def index
    @courses_new = Course::Open.where{created_at > Date.parse('27/02/2014')}.all.sort_by{ |course| course.structure.name.downcase.strip }
    @courses_old = Course::Open.where{created_at <= Date.parse('27/02/2014')}.all.sort_by{ |course| course.structure.name.downcase.strip }
    @courses_old = @courses_old + @courses_new.select{|c| c.active?}
    @courses_new = @courses_new.reject{|c| c.active? }
  end
end
