class CourseGroupsController < ApplicationController

  def index
    params[:page] ||= 1
    @course_groups = CourseGroup

    @audiences = Audience.all
    @levels    = Level.all

    params.each do |key, value|
      case key
      when 'name'
        name_string    = value + '%'
        @course_groups = @course_groups.joins{structure}.where{(name =~ name_string) | (structure.name =~ name_string)}
      when 'types'
        types = []
        types << 'CourseGroup::Lesson'   if value.include? 'lesson'
        types << 'CourseGroup::Training' if value.include? 'training'
        @course_groups         = @course_groups.where{type.like_any types}
      when 'audiences'
        @course_groups = @course_groups.joins{audiences}.where{audiences.id.eq_any value.map(&:to_i)}
      when 'levels'
        @course_groups = @course_groups.joins{levels}.where{levels.id.eq_any value.map(&:to_i)}
      when 'week_days'
        @course_groups = @course_groups.joins{plannings}.where{plannings.week_day.like_any value}
      when 'time_slots'
        time_slots = []
        value.each do |slot|
          start_time = parse_time_string LeBonCours::Application::TIME_SLOTS[slot.to_sym][:start_time]
          end_time   = parse_time_string LeBonCours::Application::TIME_SLOTS[slot.to_sym][:end_time]
          time_slots << [start_time, end_time]
        end
        @course_groups = @course_groups.joins{plannings}.where do
          time_slots.map { |start_time, end_time| ((plannings.start_time >= start_time) & (plannings.start_time <= end_time)) }.reduce(&:|)
        end
      when 'zip_codes'
        @course_groups = @course_groups.joins{structure}.where do
          value.map{ |zip_code| structure.zip_code == zip_code }.reduce(&:|)
        end

      when 'start_date'
        @course_groups = @course_groups.joins{plannings}.where{plannings.end_date >= Date.parse(value)}
      when 'end_date'
        @course_groups = @course_groups.joins{plannings}.where{plannings.start_date <= Date.parse(value)}

      when 'time_range'
        if value[:min].blank?
          start_time = parse_time_string('00:00')
        else
          start_time = parse_time_string(value[:min])
        end
        if value[:max].blank?
          end_time = parse_time_string('23:59')
        else
          end_time = parse_time_string(value[:max])
        end
        @course_groups = @course_groups.joins{plannings}.where{(plannings.start_time >= start_time) & (plannings.end_time <= end_time)}
      when 'price_range'
        # value[:min] = 0     if value[:min].blank?
        # value[:max] = 10000 if value[:max].blank?
        unless value[:min].blank? or value[:max].blank?
          @course_groups = @course_groups.joins{prices}
          @course_groups = @course_groups.where(['(prices.individual_course_price != 0 AND prices.individual_course_price >= ? AND prices.individual_course_price <= ?)
                                                  OR
                                                  (prices.annual_price != 0 AND prices.annual_price >= ? AND prices.annual_price <= ?)
                                                  OR
                                                  (prices.semester_price != 0 AND prices.semester_price >= ? AND prices.semester_price <= ?)
                                                  OR
                                                  (prices.trimester_price != 0 AND prices.trimester_price >= ? AND prices.trimester_price <= ?)
                                                  OR
                                                  (prices.month_price != 0 AND prices.month_price >= ? AND prices.month_price <= ?)
                                                  ', *[value[:min], value[:max]]*5])
        end
      end
    end
    # Eliminate all duplicates
    @course_groups = @course_groups.group{id}

    @course_groups = @course_groups.paginate(page: params[:page]).all

    respond_to do |format|
      format.html { @course_groups }
    end
  end

  def show
    @course_group         = CourseGroup.find(params[:id])
  end

  private
  def parse_time_string time_string
    if time_string.length <= 2
      time_string += ':00'
    end
    Time.parse("2000-01-01 #{time_string} UTC")
  end
end
