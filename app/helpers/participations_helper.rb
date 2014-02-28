# encoding: utf-8
module ParticipationsHelper

  def share_participation_to_facebook_friend_url(participation, friend_id=nil)
    course       = participation.course
    link         = URI.encode(jpo_structure_url(course.structure, subdomain: (Rails.env.staging? ? 'staging' : 'www')))
    redirect_uri = URI.encode(user_participations_url(current_user))
    URI.encode("http://www.facebook.com/dialog/send?app_id=#{CoursAvenue::Application::FACEBOOK_APP_ID}&link=#{link}&redirect_uri=#{redirect_uri}&to=#{friend_id}")
  end

  def share_participation_url(participation, provider = :facebook)
    course  = participation.course
    summary = "Je viens de m'inscrire aux Journées Portes Ouvertes de CoursAvenue des 5-6 avril en Ile-de-France. Comme moi, participez gratuitement à l'atelier «#{@participations.last.course.name}»."
    case provider
    when :facebook
      URI.encode("http://www.facebook.com/sharer.php?s=100&p[title]=#{course.name} par #{course.structure.name}&p[url]=#{jpo_structure_url(course.structure, subdomain: 'www')}&p[summary]=#{summary}")
    when :twitter
      URI.encode("https://twitter.com/intent/tweet?text=Je participe à un cours gratuit donné par #{course.structure.name}&via=CoursAvenue&hashtags=JPO2014&url=#{jpo_structure_url(course.structure, subdomain: 'www')}")
    end
  end

  def add_to_calendar(participation)
    structure  = participation.structure
    planning   = participation.planning
    course     = participation.course
    place_info = "Infos sur le lieu : #{planning.place.info} #{planning.place.private_info}".gsub(/\r\n/, ' ')
    # Date format
    #  <span class="_end">11-05-2012 11:38:46</span>
    link = <<-eos
    <a href="#{user_participations_url(current_user)}" title="Ajouter à mon calendrier" class="addthisevent">
        Ajouter à mon calendrier
        <span class="_start">#{l(planning.start_date)} #{l(planning.start_time, format: :default_only_time)}</span>
        <span class="_end">#{l(planning.end_date)} #{l(planning.end_time, format: :default_only_time)}</span>
        <span class="_zonecode">40</span>
        <span class="_summary">JPO CoursAvenue - #{course.name}</span>
        <span class="_description">#{place_info}</span>
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
