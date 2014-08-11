# encoding: utf-8
class ParticipationMailer < ActionMailer::Base
  include ::ActionMailerWithTextPart
  include Roadie::Rails::Automatic

  helper :plannings, :levels, :participations

  layout 'email'

  default from: "\"L'équipe CoursAvenue\" <contact@coursavenue.com>"

  ######################################################################
  # For teachers                                                       #
  ######################################################################

  # When there is no more place
  # @param  structure
  #
  # @return nil
  def no_more_place(structure)
    @structure = structure
    mail to: @structure.main_contact.email, subject: "Félicitations, vos ateliers Portes Ouvertes affichent complet !"
  end

  # When a student subscribe to a planning
  # @param  participation
  #
  # @return nil
  def user_subscribed(participation)
    @participation = participation
    @user          = participation.user
    @planning      = participation.planning
    @course        = participation.course
    @structure     = participation.course.structure
    mail to: @structure.main_contact.email, subject: "Un élève vient de s'inscrire à vos Portes Ouvertes"
  end

  # When a student subscribe to a waiting list
  # @param  participation
  #
  # @return nil
  def user_subscribed_to_waiting_list(participation)
    @participation = participation
    @user          = participation.user
    @planning      = participation.planning
    @course        = participation.course
    @structure     = participation.course.structure
    mail to: @structure.main_contact.email, subject: "Un élève vient de s'inscrire sur liste d'attente à vos Portes Ouvertes"
  end

  # When a student unsubscribe
  # @param  participation
  #
  # @return nil
  def unsubscription_for_teacher(participation)
    @participation = participation
    @user          = participation.user
    @planning      = participation.planning
    @course        = participation.course
    @structure     = participation.course.structure
    mail to: @structure.main_contact.email, subject: "Un élève vient d'annuler sa présence à vos Portes Ouvertes"
  end

  ######################################################################
  # For users                                                          #
  ######################################################################

  # When a user invite other friends to participate to his participation
  # @param  participation
  #
  # @return nil
  def invite_friends_to_jpo(participation)
    @user      = participation.user
    @planning  = participation.planning
    @course    = participation.course
    @structure = participation.course.structure
    # mail to: @user.email, subject: "Invitez vos proches à s'inscrire à votre atelier Portes Ouvertes"
  end


  # When a user participate to a planning
  # @param  participation
  #
  # @return nil
  def welcome(participation)
    @participation = participation
    @user          = participation.user
    @planning      = participation.planning
    @course        = participation.course
    @structure     = participation.course.structure
    mail to: @user.email, subject: "Votre inscription aux Journées Portes Ouvertes est validée"
  end

  # When a user participate and appears on a waiting
  # @param  participation
  #
  # @return nil
  def welcome_to_waiting_list(participation)
    @participation = participation
    @user          = participation.user
    @planning      = participation.planning
    @course        = participation.course
    @structure     = participation.course.structure
    mail to: @user.email, subject: "Votre inscription en liste d'attente aux Journées Portes Ouvertes est validée"
  end

  # When a user was on a waiting list and a place opened
  # @param  participation
  #
  # @return nil
  def a_place_opened(participation)
    @participation = participation
    @user          = participation.user
    @planning      = participation.planning
    @course        = participation.course
    @structure     = participation.course.structure
    mail to: @user.email, subject: "Votre inscription vient d'être prise en compte"
  end

  # When a user unsubscribe
  # @param  participation
  #
  # @return nil
  def unsubscription(participation)
    @participation = participation
    @user          = participation.user
    @planning      = participation.planning
    @course        = participation.course
    @structure     = participation.course.structure
    mail to: @user.email, subject: "Votre désinscription a bien été prise en compte"
  end

  def inform_invitation_success_for_jpo(invited_user, user, participation)
    return if invited_user.referrer_type == 'Structure'
    @referer       = invited_user.referrer
    @invited_user  = user
    @participation = participation
    @planning      = participation.planning
    mail to: @referer.email, subject: "Félicitations ! L'un de vos proches s'est inscrit aux Portes Ouvertes"
  end

  def fill_other_participants_email(participation)
    @participation = participation
    @user          = participation.user
    mail to: @user.email, subject: "Renseignez les emails des participants à vos ateliers Portes Ouvertes"
  end

  def recap(user)
    @participations = user.participations.not_canceled
    @participations = @participations.all.sort_by{ |p| [p.planning.start_date, p.planning.start_time] }
    @participations = @participations.sort_by{ |p| p.waiting_list? ? 1 : 0 }
    @user           = user
    @invited_friends = 0
    @participations.each do |participation|
      @invited_friends += participation.nb_adults - 1 if participation.nb_adults > 1
    end
    if @participations.length == 1
      subject = "Rappel de votre inscription - #{I18n.l(@participations.first.planning.start_date, format: :semi_long)} à #{I18n.l(@participations.first.planning.start_time, format: :short)}"
    else
      subject = "Rappel de vos inscriptions - #{@participations.length} ateliers pour ce week-end"
    end
    mail to: @user.email, subject: subject
  end

  def recap_for_teacher(structure)
    @structure    = structure
    @open_courses = structure.courses.open_courses
    mail to: structure.contact_email, subject: 'Récapitulatif de vos inscriptions pour les Portes Ouvertes de ce week-end'
  end

  def recap_from_friend(invited_user, invited_by)
    @participations = invited_user.invited_participations.not_canceled.not_in_waiting_list
    @participations = @participations.sort_by{|p| [p.planning.start_date, p.planning.start_time]}
    return if @participations.empty?
    @invited_user    = invited_user
    @invited_by      = invited_by
    mail to: @invited_user.email, subject: "Récapitulatif de vos inscriptions aux ateliers des Portes Ouvertes CoursAvenue"
  end

end
