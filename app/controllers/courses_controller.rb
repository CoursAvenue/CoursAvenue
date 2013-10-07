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
    init_geoloc
    cookies[:search_path] = request.fullpath
    # fresh_when etag: [@courses, ENV["ETAG_VERSION_ID"]], public: true
    # expires_in 1.minutes, public: true
  end

  def show
    @course    = Course.find(params[:id])
    @structure = @course.structure
    redirect_to structure_course_path(@structure, @course), status: 301
  end

  private

  def init_geoloc
    @locations = []
    latitude  = params[:lat].to_f
    longitude = params[:lng].to_f
    radius    = (params[:radius] || 7).to_f
    @course_places = {} # Keep places that are in the radius
    @courses.each do |course|
      @course_places[course] = course.locations_around(latitude, longitude, radius)
      @locations            += @course_places[course]
    end
    @json_locations_addresses = @locations.uniq.to_gmaps4rails do |place, marker|
      marker.picture({
                      :marker_anchor => [10, true],
                      :rich_marker   => "<div class='map-marker-image disabled' style='font-size: 13px; top: -2em;'><a href='javascript:void(0)'></a></div>"
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
