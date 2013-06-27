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
    @courses = CourseSearch.search params
    init_geoloc
    cookies[:search_path] = request.fullpath
    # fresh_when etag: [@courses, ENV["ETAG_VERSION_ID"]], public: true
    # expires_in 1.minutes, public: true
  end

  def show
    @course             = Course.find(params[:id])
    @comment            = @course.comments.build
    @comments           = @course.comments.order('created_at DESC').reject(&:new_record?)
    @city               = @course.city
    @structure          = @course.structure
    @medias             = @structure.medias
    @structure_comments = @structure.comments.order('created_at DESC')
    @place              = @course.place
    @plannings          = @course.plannings
    @subjects           = @course.subjects
    @has_promotion      = @course.has_promotion?
    @has_nb_place       = @course.plannings.map(&:nb_place_available).compact.any?
    @reservation        = Reservation.new
    @best_price         = @course.best_price
    # @similar_courses    = @course.similar_courses

    @json_place_address = @place.to_gmaps4rails do |place, marker|
      marker.title   place.name
      marker.json({ id: place.id })
    end
    # fresh_when etag: [@course, @comments.first, ENV["ETAG_VERSION_ID"]], public: true
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
