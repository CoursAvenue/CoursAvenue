# encoding: utf-8
module ParticipationRequestsHelper

  def participation_request_color(participation_request)
    if participation_request.pending?
      'orange'
    elsif participation_request.accepted?
      'green'
    elsif participation_request.canceled?
      'red'
    end
  end

  def add_to_calendar(participation_request)
    structure  = participation_request.structure
    course     = participation_request.course
    place      = participation_request.place
    place_info = "Infos sur le lieu : #{place.info} #{place.private_info}".gsub(/\r\n/, ' ') if place and (place.info.present? or place.private_info.present?)
    # Date format
    #  <span class="_end">11-05-2012 11:38:46</span>
    link = <<-eos
    <a href="#{user_participation_requests_path(current_user)}" title="Ajouter à mon calendrier" class="addthisevent v-middle">
        <div class="date">
          <span class="mon">#{t('date.abbr_month_names')[participation_request.date.month].upcase.gsub('.', '')}</span>
          <span class="day">#{participation_request.date.day}</span>
          <div class="bdr1"></div>
          <div class="bdr2"></div>
        </div>
        <div class="desc">
          <p>
            <strong class="hed">#{truncate course.name, length: 24}</strong>
            <span class="des">Lieu : #{truncate place.try(:address), length: 28}<br />Date : #{l(participation_request.date, format: :semi_short)} à #{l(participation_request.start_time, format: :short)}</span>
          </p>
        </div>

        <span class="_start">#{l(participation_request.date)} #{l(participation_request.start_time, format: :default_only_time)}</span>
        <span class="_end">#{l(participation_request.date)} #{l(participation_request.end_time, format: :default_only_time)}</span>
        <span class="_zonecode">40</span>
        <span class="_summary">#{course.name}</span>
        <span class="_description">#{place_info}</span>
        <span class="_location">#{place.try(:address)}</span>
        <span class="_organizer">CoursAvenue en collaboration avec #{structure.name}</span>
        <span class="_organizer_email">contact@coursavenue.com</span>
        <span class="_all_day_event">false</span>
        <span class="_date_format">DD/MM/YYYY</span>
    </a>
    eos
    link.html_safe
  end

  def add_to_calendar_small(participation_request)
    structure  = participation_request.structure
    course     = participation_request.course
    place      = participation_request.place
    place_info = "Infos sur le lieu : #{place.info} #{place.private_info}".gsub(/\r\n/, ' ') if place and (place.info.present? or place.private_info.present?)
    # Date format
    #  <span class="_end">11-05-2012 11:38:46</span>
    link = <<-eos
    <a href="#{user_participation_requests_path(current_user)}" title="Ajouter à mon calendrier" class="addthisevent v-middle calendar--small">
        <div class="date">
          <span class="mon">#{t('date.abbr_month_names')[participation_request.date.month].upcase.gsub('.', '')}</span>
          <span class="day">#{participation_request.date.day}</span>
        </div>
        <span class="_start">#{l(participation_request.date)} #{l(participation_request.start_time, format: :default_only_time)}</span>
        <span class="_end">#{l(participation_request.date)} #{l(participation_request.end_time, format: :default_only_time)}</span>
        <span class="_zonecode">40</span>
        <span class="_summary">#{course.name}</span>
        <span class="_description">#{place_info}</span>
        <span class="_location">#{place.try(:address)}</span>
        <span class="_organizer">CoursAvenue en collaboration avec #{structure.name}</span>
        <span class="_organizer_email">contact@coursavenue.com</span>
        <span class="_all_day_event">false</span>
        <span class="_date_format">DD/MM/YYYY</span>
    </a>
    eos
    link.html_safe
  end

  def add_to_calendar_plain_text(participation_request, link_text='Ajouter à mon calendrier')
    structure  = participation_request.structure
    course     = participation_request.course
    place      = participation_request.place
    place_info = "Infos sur le lieu : #{place.info} #{place.private_info}".gsub(/\r\n/, ' ') if place and (place.info.present? or place.private_info.present?)
    # Date format
    #  <span class="_end">11-05-2012 11:38:46</span>
    link = <<-eos
    <a href="#{user_participation_requests_path(current_user)}" title="Ajouter à mon calendrier" class="addthisevent v-middle calendar--plain">
        #{link_text}
        <span class="_start">#{l(participation_request.date)} #{l(participation_request.start_time, format: :default_only_time)}</span>
        <span class="_end">#{l(participation_request.date)} #{l(participation_request.end_time, format: :default_only_time)}</span>
        <span class="_zonecode">40</span>
        <span class="_summary">#{course.name}</span>
        <span class="_description">#{place_info}</span>
        <span class="_location">#{place.try(:address)}</span>
        <span class="_organizer">CoursAvenue en collaboration avec #{structure.name}</span>
        <span class="_organizer_email">contact@coursavenue.com</span>
        <span class="_all_day_event">false</span>
        <span class="_date_format">DD/MM/YYYY</span>
    </a>
    eos
    link.html_safe
  end
end
