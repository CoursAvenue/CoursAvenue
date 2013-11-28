# encoding: utf-8
class Structures::CoursesController < ApplicationController

  def index

    @course_search = CourseSearch.search(params)
    @courses       = @course_search.results

    respond_to do |format|
      format.json { render json: @courses, each_serializer: CourseSerializer }
    end
  end

  def show
    begin
      @structure = Structure.friendly.find params[:structure_id]
    rescue ActiveRecord::RecordNotFound
      place = Place.find params[:structure_id]
      redirect_to structure_course_path(place.structure, params[:id]), status: 301
      return
    end
    @course             = Course.friendly.find(params[:id])
    @comment            = @course.comments.build
    @comments           = @structure.comments.accepted.reject(&:new_record?)
    @medias             = @structure.medias
    @locations          = @course.locations
    @places             = @course.places
    if @course.is_lesson?
      @plannings = @course.plannings.order('week_day ASC, start_time ASC')
    else
      @plannings = @course.plannings.order('start_date ASC, start_time ASC')
    end
    @plannings_grouped_by_places = @plannings.future.group_by(&:place)
    @subjects                    = @course.subjects
    @price_range                 = @course.price_range
    @prices                      = @course.book_tickets + @course.subscriptions
    @location_index_hash = {}
    location_index       = 0
    @json_place_address = @locations.to_gmaps4rails do |location, marker|
      location_index += 1
      @location_index_hash[location] = location_index
      marker.title   location.name
      marker.picture({
                      :marker_anchor => [10, true],
                      :rich_marker   => "<div class='map-marker-image'><a href='javascript:void(0)'><span>#{location_index}</span></a></div>"
                     })
      marker.json({ id: location.id })
    end
  end
end
