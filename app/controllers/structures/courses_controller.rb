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
    if params[:course_type].present?
      @courses = @structure.courses.send(params[:course_type]).order('name ASC')
    else
      @courses = @structure.courses.order('name ASC')
    end
    # Reject courses that does not have upcoming plannings if it is a training
    # if params[:course_type] == 'trainings'
    @courses = @courses.reject{ |course| course.plannings.future.empty? }
    # end

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
end
