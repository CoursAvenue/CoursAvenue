class CoursesController < ApplicationController

  def index
    unless params[:search].blank?
      d = params[:search][:discipline]
      @courses = Course.joins{discipline}.where{discipline.name =~ d}.all
    else
      @courses = Course.all
    end
  end

  def show
    @course = Course.find(params[:id])
  end

end
