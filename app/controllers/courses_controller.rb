class CoursesController < ApplicationController

  def show
    @city               = City.find(params[:city_id])
    @course             = Course.find(params[:id])
    @structure          = @course.structure
    @plannings          = @course.plannings
    @subjects           = @course.subjects

    @similar_courses = @course.similar_courses

    @json_structure_address = @structure.to_gmaps4rails do |structure, marker|
      marker.title   structure.name
      marker.json({ id: structure.id })
    end
    respond_to do |format|
      format.html
      format.json {render json: @course, serializer: CourseSerializer}
    end

  end
end
