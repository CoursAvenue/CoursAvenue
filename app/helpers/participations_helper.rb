# encoding: utf-8
module ParticipationsHelper

  def share_participation_url(participation, provider = :facebook)
    course = participation.course
    case provider
    when :facebook
      URI.encode("http://www.facebook.com/sharer.php?s=100&p[title]=#{course.name} par #{course.structure.name}&p[url]=#{jpo_structure_url(course.structure, subdomain: 'www')}&p[summary]=#{truncate(course.description, length: 200)}")
    when :twitter
      URI.encode("https://twitter.com/intent/tweet?text=Je participe à un cours gratuit donné par #{course.structure.name}&via=CoursAvenue&hashtags=JPO2014&url=#{jpo_structure_url(course.structure, subdomain: 'www')}")
    end
  end

  def add_to_calendar(participation)
    structure = participation.structure
    planning  = participation.planning
    course    = participation.course
    # Date format
    #  <span class="_end">11-05-2012 11:38:46</span>
    link = <<-eos
    <a href="#{user_participations_url(current_user)}" title="Ajouter à mon calendrier" class="addthisevent">
        Ajouter à mon calendrier
        <span class="_start">#{l(planning.start_date)} #{l(planning.start_time, format: :default_only_time)}</span>
        <span class="_end">#{l(planning.end_date)} #{l(planning.end_time, format: :default_only_time)}</span>
        <span class="_zonecode">40</span>
        <span class="_summary">#{course.name}</span>
        <span class="_description">Journées Portes Ouvertes CoursAvenue</span>
        <span class="_location">#{planning.place.location.address}</span>
        <span class="_organizer">CoursAvenue en collaboration avec #{structure.name}</span>
        <span class="_organizer_email">#{structure.main_contact.email}</span>
        <span class="_all_day_event">false</span>
        <span class="_date_format">DD/MM/YYYY</span>
    </a>
    eos
    link.html_safe
  end
end
