# encoding: utf-8
class Structures::CoursesController < ApplicationController

  def show
    @course             = Course.find(params[:id])
    @comment            = @course.comments.build
    @comments           = @course.comments.order('created_at DESC').reject(&:new_record?)
    @city               = @course.city
    @structure          = @course.structure
    @medias             = @structure.medias
    @structure_comments = @structure.comments.order('created_at DESC')
    @place              = @course.place
    if @course.is_lesson?
      @plannings = @course.plannings.order('week_day ASC, start_time ASC')
    else
      @plannings = @course.plannings.order('start_date ASC, start_time ASC')
    end
    @plannings          = @plannings.future.group_by(&:level_ids)
    @subjects           = @course.subjects
    @has_promotion      = @course.has_promotion?
    @has_nb_place       = @course.plannings.map(&:nb_place_available).compact.any?
    @reservation        = Reservation.new
    @best_price         = @course.best_price

    @json_place_address = @place.to_gmaps4rails do |place, marker|
      marker.title   place.name
      marker.json({ id: place.id })
    end
  end
end
