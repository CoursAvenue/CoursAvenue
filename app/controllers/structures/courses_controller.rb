# encoding: utf-8
class Structures::CoursesController < ApplicationController

  def index
    @structure = Structure.find params[:structure_id]
    if params[:course_type].present?
      @courses = @structure.courses.send(params[:course_type])
    else
      @courses = @structure.courses
    end

    @json_courses = []
    @courses.each do |course|
      @json_courses << CourseSerializer.new(course, {
        root: false,
        structure: @structure
      })
    end
    respond_to do |format|
      # We use courses root to be able to add meta.
      # It's used in the structureProfile backbone app.
      format.json { render json: { courses: @json_courses } }
      format.html { redirect_to structure_path(@structure)}
    end
  end

  def show
    @structure = Structure.friendly.find params[:structure_id]
    respond_to do |format|
      format.html { redirect_to structure_path(@structure), status: 301 }
    end
  end
end
