class CoursesController < ApplicationController

  def show
    @course             = Course.find(params[:id])
    @city               = @course.city
    @structure          = @course.structure
    @place              = @course.place
    @plannings          = @course.plannings
    @subjects           = @course.subjects
    @has_promotion      = @course.has_promotion
    @has_nb_place       = @course.plannings.map(&:nb_place_available).compact.any?

    @similar_courses = @course.similar_courses

    @json_place_address = @place.to_gmaps4rails do |place, marker|
      marker.title   place.name
      marker.json({ id: place.id })
    end
    respond_to do |format|
      format.html
      format.json {render json: @course, serializer: CourseSerializer}
    end

  end
end
