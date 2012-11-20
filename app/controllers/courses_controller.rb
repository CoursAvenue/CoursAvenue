class CoursesController < ApplicationController

  def index
    params[:page] ||= 1
    @courses = Course

    @audiences = Audience.all
    @levels    = Level.all


    unless params[:search].blank?
      params[:search].each do |key, value|
        case key
        when 'discipline'
          discipline_name  = value + '%'
          @courses         = @courses.joins{discipline}.where{discipline.name =~ discipline_name}
        when 'types'
          #type_name = (value == 'training' ? 'Course::Training' : 'Course::Lesson')
          types = []
          types << 'Course::Lesson' if value.include? 'lesson'
          types << 'Course::Training' if value.include? 'training'
          @courses         = @courses.where{type.like_any types}
        when 'audiences'
          @courses = @courses.joins{audiences}.where{audiences.name.like_any value}
        when 'levels'
          @courses = @courses.joins{levels}.where{levels.name.like_any value}
        end
      end
    end
    @courses = @courses.paginate(page: params[:page]).all

    respond_to do |format|
      format.html { @courses }
    end
  end

  def show
    @course = Course.find(params[:id])
  end

end
