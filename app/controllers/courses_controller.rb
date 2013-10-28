# encoding: utf-8
class CoursesController < ApplicationController

  before_action :prepare_search, only: [:index]

  def index
    redirect_to structures_path, status: 301
  end

  def show
    @course    = Course.friendly.find(params[:id])
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

  # def course_params
  #   params.require(:course).permit(:name, :type, :description,
  #                                   :active, :info, :rating, :is_promoted,
  #                                   :price_details,
  #                                   :has_online_payment,
  #                                   :homepage_image,
  #                                   :image,
  #                                   :frequency,
  #                                   :registration_date,
  #                                   :is_individual, :is_for_handicaped,
  #                                   :trial_lesson_info, # Info prix
  #                                   :conditions,
  #                                   :partner_rib_info,
  #                                   :audition_mandatory,
  #                                   :refund_condition,
  #                                   :cant_be_joined_during_year,
  #                                   :nb_participants,
  #                                   :no_class_during_holidays,
  #                                   :start_date, :end_date,
  #                                   :subject_ids, :level_ids, :audience_ids, :place_id, :active,
  #                                   :book_tickets_attributes, :prices_attributes, :registration_fees_attributes)

  # end

end
