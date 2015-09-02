# encoding: utf-8
class Structures::CoursesController < ApplicationController

  def show
    @structure = Structure.friendly.find params[:structure_id]
    @course    = @structure.courses.find(params[:id])
    respond_to do |format|
      format.json { render json: @course, serializer: CourseSerializer }
    end
  end

  def index
    @structure = Structure.friendly.find params[:structure_id]
    @courses   = @structure.courses
    respond_to do |format|
      format.json { render json: @courses, each_serializer: CourseSerializer }
    end
  end
end
