# encoding: utf-8
class CoursesController < ApplicationController

  before_action :prepare_search, only: [:index]

  def index
    redirect_to structures_path, status: 301
  end

  def show
    @course    = Course.friendly.find(params[:id])
    @structure = @course.structure
    redirect_to structure_course_path(@structure, @course), status: 301
  end

end
