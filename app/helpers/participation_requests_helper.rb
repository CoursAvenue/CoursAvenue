# encoding: utf-8
module ParticipationRequestsHelper

  def participation_request_course_description(participation_request)
    output = ''
    output << content_tag(:strong) do
      o = participation_request.course.name
      if participation_request.course.is_lesson?
        o << "le #{week_day_for(participation_request.planning).downcase} "
      else
        o << "le #{planning_date_for(participation_request.planning).downcase} "
      end
      o
      o << "#{planning_time_for(participation_request.planning, false)}. "
    end
    output << join_levels_text(participation_request.planning)
    output << "(#{join_audiences(participation_request.planning)}), "
    output << participation_request.planning.place.name if participation_request.planning.place
    output.html_safe
  end

  # Print state of participation with icon and color
  #
  # @return String as HTML
  def participation_request_state_html(participation_request)
    content_tag :div, class: participation_request_color(participation_request) do
      output = ""
      output << participation_request_icon(participation_request)
      output << " "
      output << content_tag(:strong, t("participation_request.state.#{participation_request.state}"))
      output.html_safe
    end

  end

  def participation_request_color(participation_request)
    if participation_request.pending?
      'orange'
    elsif participation_request.accepted?
      'green'
    elsif participation_request.declined?
      'red'
    end
  end

  def participation_request_icon(participation_request)
    if participation_request.pending?
      content_tag(:i, nil, class: 'fa fa-clock')
    elsif participation_request.accepted?
      content_tag(:i, nil, class: 'fa fa-check')
    elsif participation_request.declined?
      content_tag(:i, nil, class: 'fa fa-times')
    end
  end

  # Description to Structure or User for a request
  # @param participation_request [type] [description]
  # @param to_whom='to_structure' [type] [description]
  #
  # @return String
  def participation_request_long_description(participation_request, resource_name='structure')
    date = "#{l(@participation_request.date, format: :semi_short)} à #{l(@participation_request.start_time, format: :short)}"
    if participation_request.pending?
      if participation_request.last_modified_by
        t("participation_request.state.to_#{resource_name}.last_modified_by_#{participation_request.last_modified_by.downcase}.long_description.#{participation_request.state}_html", structure_name: participation_request.structure.name, user_name: participation_request.user.name, date: date, course_name: participation_request.course.name )
      else
        t("participation_request.state.long_description.#{participation_request.state}_html")
      end
    elsif participation_request.accepted?
      if participation_request.last_modified_by
        t("participation_request.state.to_#{resource_name}.last_modified_by_#{participation_request.last_modified_by.downcase}.long_description.#{participation_request.state}_html", structure_name: participation_request.structure.name, user_name: participation_request.user.name, date: date, course_name: participation_request.course.name )
      else
        t("participation_request.state.long_description.#{participation_request.state}_html", structure_name: participation_request.structure.name, user_name: participation_request.user.name, date: date, course_name: participation_request.course.name )
      end
    elsif participation_request.declined?
      if participation_request.last_modified_by
        t("participation_request.state.to_#{resource_name}.last_modified_by_#{participation_request.last_modified_by.downcase}.long_description.#{participation_request.state}_html", structure_name: participation_request.structure.name, user_name: participation_request.user.name, course_name: participation_request.course.name )
      else
        t("participation_request.state.long_description.#{participation_request.state}_html", structure_name: participation_request.structure.name, user_name: participation_request.user.name, course_name: participation_request.course.name )
      end
    end
  end
end
