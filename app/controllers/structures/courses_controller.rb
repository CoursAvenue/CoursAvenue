# encoding: utf-8
class Structures::CoursesController < ApplicationController

  def index
    params.delete(:page) if params[:page]
    @structure            = Structure.find params[:structure_id]
    params[:structure_id] = @structure.id
    @planning_search      = PlanningSearch.search(params)
    @plannings            = @planning_search.results
    @courses              = []

    @plannings = @plannings.sort do |planning_a, planning_b|
      [planning_a.week_day, planning_a.start_date, planning_a.start_time] <=> [planning_b.week_day, planning_b.start_date, planning_b.start_time]
    end

    @plannings.group_by(&:course_id).each do |course_id, plannings|
      course    = Course.find(course_id)
      next unless course.active
      @courses << CourseSerializer.new(course, {
        root: false,
        structure: @structure,
        search_term: params[:search_term],
        jpo: (params[:course_types] == ['open_course']),
        plannings: plannings
      })
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

    respond_to do |format|
      if @course.is_open?
        format.html { redirect_to jpo_structure_path(@structure), status: 301 }
      elsif @course.active
        format.html
        format.json { render json: CourseSerializer.new(@course).to_json }
      else
        format.html { redirect_to root_path, notice: "Ce cours n'est pas visible.", status: 301 }
      end
    end
  end
end
