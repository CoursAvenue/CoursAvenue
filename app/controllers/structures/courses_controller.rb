# encoding: utf-8
class Structures::CoursesController < ApplicationController

  def show
    begin
      @structure = Structure.find params[:structure_id]
    rescue ActiveRecord::RecordNotFound
      place = Place.find params[:structure_id]
      redirect_to structure_course_path(place.structure, params[:id]), status: 301
      return
    end
    @course             = Course.find(params[:id])
    @comment            = @course.comments.build
    @comments           = @course.comments.order('created_at DESC').reject(&:new_record?)
    @medias             = @structure.medias
    @structure_comments = @structure.comments.order('created_at DESC')
    @locations          = @course.locations
    @places             = @course.places
    if @course.is_lesson?
      @plannings = @course.plannings.order('week_day ASC, start_time ASC')
    else
      @plannings = @course.plannings.order('start_date ASC, start_time ASC')
    end
    @plannings_grouped_by_places = @plannings.future.group_by(&:place)
    @subjects                    = @course.subjects
    @has_promotion               = @course.has_promotion?
    @has_nb_place                = @course.plannings.map(&:nb_place_available).compact.any?
    @reservation                 = Reservation.new
    @best_price                  = @course.best_price
    @prices                      = @course.prices.order('number ASC')
    @location_index_hash = {}
    location_index       = 0
    @json_place_address = @locations.to_gmaps4rails do |location, marker|
      location_index += 1
      @location_index_hash[location] = location_index
      marker.title   location.name
      marker.picture({
                      :marker_anchor => [10, true],
                      :rich_marker   => "<div class='map-marker-image' style='font-size: 13px; top: -2em;'><a href='javascript:void(0)'><span>#{location_index}</span></a></div>"
                     })
      marker.json({ id: location.id })
    end
  end
end
