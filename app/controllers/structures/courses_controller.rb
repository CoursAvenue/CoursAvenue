# encoding: utf-8
class Structures::CoursesController < ApplicationController

  def index
    params.delete(:page) if params[:page]
    @structure            = Structure.find params[:structure_id]
    params[:structure_id] = @structure.id
    params[:per_page]     = 1000 # Show all the plannings
    @planning_search      = PlanningSearch.search(params)
    @plannings            = @planning_search.results
    @courses              = []

    @total_planning_search = PlanningSearch.search({ structure_id: @structure.id,
                                                     course_types: params[:course_types] || [],
                                                     visible: true }).total

    @plannings = @plannings.sort do |planning_a, planning_b|
      [planning_a.week_day, planning_a.start_date, planning_a.start_time].compact <=> [planning_b.week_day, planning_b.start_date, planning_b.start_time].compact
    end

    if params[:structure_id] == 2802 or params[:structure_id] == '2802'
      logger.debug "--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------"
      logger.debug "Plannings : #{@plannings.map(&:id)}"
      logger.debug "Search params : #{params}"
      logger.debug "Total plannings : #{@total_planning_search} / #{@planning_search.total}"
    end
    @plannings.group_by(&:course_id).each do |course_id, plannings|
      logger.debug "Plannings grouped : #{course_id}"
      course = Course.find(course_id)
      if !course.is_published?
        if params[:structure_id] == 2802 or params[:structure_id] == '2802'
          logger.debug "Course is not published"
          logger.debug "Non visible plannings : #{course.plannings.future.visible.count}"
        end
        @total_planning_search = @total_planning_search - course.plannings.future.visible.count
        next
      end
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
