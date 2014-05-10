# encoding: utf-8
class Pro::OpenCoursesController < Pro::ProController
  before_action :authenticate_pro_super_admin!
  layout 'admin'

  def index
    @courses_inactive = Course::Open.where( active: false ).all.sort_by{ |course| course.structure.name.downcase.strip }
    @courses_active = Course::Open.where( active: true ).all.sort_by{ |course| course.structure.name.downcase.strip }
  end

  def fulfillment
    @structures = Course::Open.active.all.map(&:structure).uniq
  end

  def fulfillment_per_courses
  end
end
