# encoding: utf-8
class CoursesController < ApplicationController

  before_filter :prepare_search, only: [:index]

  def index
    if params[:subject_id]
      begin
        @subject = Subject.find params[:subject_id]
      rescue
        redirect_to courses_path, status: 301
      end
    end
    @courses           = CourseSearch.search params
    # @course_collection = @courses
    # if @courses.length == 0 and @subject
    #   if @subject.parent
    #     @other_courses = CourseSearch.search params.merge subject_id: @subject.parent.slug
    #   else
    #     new_params = params.dup # Duplicate params to keep subject_id in actual params
    #     new_params.delete :subject_id
    #     @other_courses = CourseSearch.search new_params
    #   end
    #   @course_collection = @other_courses
    # end
    init_geoloc
    cookies[:search_path] = request.fullpath
    # fresh_when etag: [@courses, ENV["ETAG_VERSION_ID"]], public: true
    # expires_in 1.minutes, public: true
  end

  def show
    @course             = Course.find(params[:id])
    @place              = @course.place
    redirect_to place_course_path(@place, @course), status: 301
  end

  private

  def init_geoloc
    @course_places = @courses.collect{|course| course.place}.uniq
    place_index = 0
    @json_place_addresses = @course_places.to_gmaps4rails do |place, marker|
      place_index += 1
      marker.picture({
                      :marker_anchor => [10, true],
                      :rich_marker   => "<div class='map-marker-image' style='font-size: 13px; top: -2em;'><a href='#'><span>#{place_index}</span></a></div>"
                     })
      marker.title   place.name
      marker.json({ id: place.id })
    end
  end

  def prepare_search
    @audiences = Audience.all
    @levels    = Level.all
  end
end
