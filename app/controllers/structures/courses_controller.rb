# encoding: utf-8
class Structures::CoursesController < ApplicationController

  def index
    @structure       = Structure.find params[:structure_id]
    @planning_search = PlanningSearch.search(params)
    @plannings       = @planning_search.results
    @courses         = []

    if params[:course_types] == ['open_course']
      planning_serializer_options = { jpo: true }
    else
      planning_serializer_options = {}
    end
    @plannings.group_by(&:course_id).each do |course_id, plannings|
      course = Course.find(course_id)
      @courses << CourseSerializer.new(course, { root: false, structure: @structure, jpo: (params[:course_types] == ['open_course'])})
    end

    respond_to do |format|
      format.json { render json: @courses }
      format.html { redirect_to structure_path(@structure)}
    end
  end

  def show
    @structure = Structure.friendly.find params[:structure_id]
    @course    = Course.friendly.find(params[:id])
    @comment   = @course.comments.build
    @comments  = @structure.comments.accepted.reject(&:new_record?)
    @medias    = @structure.medias
    @locations = @course.locations
    @places    = @course.places
    if @course.is_lesson?
      @plannings = @course.plannings.order('week_day ASC, start_time ASC')
    else
      @plannings = @course.plannings.order('start_date ASC, start_time ASC')
    end
    @plannings_grouped_by_places = @plannings.future.group_by(&:place)
    @subjects                    = @course.subjects
    @price_range                 = @course.price_range
    @prices                      = @course.book_tickets + @course.subscriptions
    @location_index_hash         = {}
    location_index               = 0
    @locations.each_with_index do |location, index|
      @location_index_hash[location] = index + 1
    end
    respond_to do |format|
      if @course.is_open?
        format.html { redirect_to jpo_structure_path(@structure), status: 301 }
      elsif @course.active
        format.html
      else
        format.html { redirect_to root_path, notice: "Ce cours n'est pas visible.", status: 301 }
      end
    end
  end
end
