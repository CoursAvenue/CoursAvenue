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
    places = []
    latitude  = params[:lat].to_f
    longitude = params[:lng].to_f
    radius    = params[:radius].to_f
    # Keep places that are in the correct radius
    @course_places = {}
    @courses.each do |course|
      @course_places[course] = course.places.uniq.reject do |place|
        Geocoder::Calculations.distance_between([latitude, longitude], [place.latitude, place.longitude], unit: :km) > radius
      end
      places += @course_places[course]
    end
    index = 0
    @place_id_index = {}
    @json_structures_addresses = places.uniq.to_gmaps4rails do |place, marker|
      index += 1
      @place_id_index[place.id] = index
      marker.picture({
                      :marker_anchor => [10, true],
                      :rich_marker   => "<div class='map-marker-image' style='font-size: 13px; top: -2em;'><a href='javascript:void(0)'><span>#{index}</span></a></div>"
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
