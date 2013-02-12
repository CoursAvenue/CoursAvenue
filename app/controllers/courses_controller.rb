class CoursesController < ApplicationController

  def show
    @course             = Course.find(params[:id])
    @city               = @course.city
    @structure          = @course.structure
    @plannings          = @course.plannings
    @subjects           = @course.subjects
    @has_promotion      = @course.has_promotion
    @has_nb_place       = @course.plannings.map(&:nb_place_available).compact.any?

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
