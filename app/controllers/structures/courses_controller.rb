# encoding: utf-8
class Structures::CoursesController < ApplicationController

  def index
    params.delete(:page) if params[:page]
    @structure            = Structure.find params[:structure_id]
    params[:structure_id] = @structure.id
    params[:per_page]     = 1000 # Show all the plannings
    params[:is_published] = true # Show all the plannings
    @planning_search      = PlanningSearch.search(params)
    @plannings            = @planning_search.results
    @courses              = []

    @total_planning_search = PlanningSearch.search({ structure_id: @structure.id,
                                                     course_types: params[:course_types] || [],
                                                     is_published: true,
                                                     visible: true, per_page: 1000 }).results.count
                                                     # We don't use `.total` here to prevent from missing document
                                                     # See: https://www.coursavenue.com/etablissements/2802/cours.json?course_types%5B%5D=training for example

    @plannings = @plannings.sort do |planning_a, planning_b|
      [planning_a.week_day, planning_a.start_date, planning_a.start_time].compact <=> [planning_b.week_day, planning_b.start_date, planning_b.start_time].compact
    end

    @plannings.group_by(&:course_id).each do |course_id, plannings|
      course = Course.find(course_id)
      @courses << CourseSerializer.new(course, {
        root: false,
        structure: @structure,
        search_term: params[:search_term],
        plannings: plannings.select(&:visible)
      })
    end

    respond_to do |format|
      # We use courses root to be able to add meta.
      # It's used in the structureProfile backbone app.
      format.json { render json: { courses: @courses, meta: { total_not_filtered: @total_planning_search  } } }
      format.html { redirect_to structure_path(@structure)}
    end
  end

  def show
    @structure = Structure.friendly.find params[:structure_id]
    respond_to do |format|
      format.html { redirect_to structure_path(@structure), status: 301 }
    end
  end
end
