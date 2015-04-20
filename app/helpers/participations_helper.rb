# encoding: utf-8
module ParticipationsHelper

  #
  # Returns the name of the user
  # If it is for kid, show (+ XX enfants) or (2 adultes + 1 enfant)
  # @param  participation
  #
  # @return string
  def participation_user_name(participation)
    return_string = participation.user.name
    if participation.size > 1
      return_string << " ("
      return_string << "#{pluralize participation.nb_adults, 'adulte'}" if participation.nb_adults > 0
      return_string << " + " if participation.nb_adults > 0 and participation.nb_kids > 0
      return_string << "#{pluralize participation.nb_kids, 'enfant'}" if participation.nb_kids > 0
      return_string << ")"
    end
    return_string
  end

  # See Facebook doc:
  # https://developers.facebook.com/docs/reference/dialogs/send/
  def share_participation_to_facebook_friend_url(participation, friend_id=nil)
    if participation
      course = participation.course
      link   = URI.encode(jpo_structure_url(course.structure, subdomain: (Rails.env.staging? ? 'staging' : 'www')))
    else
      link = URI.encode(open_courses_url(subdomain: 'www'))
    end
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
      URI.encode("https://twitter.com/intent/tweet?text=Je participe à un cours gratuit donné par #{course.structure.name}&via=CoursAvenue&hashtags=JPO14&url=#{jpo_structure_url(course.structure, subdomain: 'www')}")
    end
  end
end
