# encoding: utf-8
class ParticipationMailer < ActionMailer::Base
  helper :plannings, :levels

  layout 'email'

  default from: "\"L'équipe de CoursAvenue.com\" <contact@coursavenue.com>"

  def unsubscription_for_teacher(participation)
    @user      = participation.user
    @planning  = participation.planning
    @course    = participation.course
    @structure = participation.course.structure
    mail to: @user.email, subject: "Un élève vient d'annuler sa présence à vos Journées Portes Ouvertes"
  end

  # User subscribe to a waiting list
  #   Mail to teacher
  def user_subscribed_to_waiting_list(participation)
    @user      = participation.user
    @planning  = participation.planning
    @course    = participation.course
    @structure = participation.course.structure
    mail to: @user.email, subject: "Un élève vient de s'inscrire à vos Journées Portes Ouvertes"
  end

  # User subscribes
  #   Mail to teacher
  def user_subscribed(participation)
    @user      = participation.user
    @planning  = participation.planning
    @course    = participation.course
    @structure = participation.course.structure
    mail to: @user.email, subject: "Un élève vient de s'inscrire à vos Journées Portes Ouvertes"
  end

  def welcome(participation)
    @user      = participation.user
    @planning  = participation.planning
    @course    = participation.course
    @structure = participation.course.structure
    mail to: @user.email, subject: "Votre inscription aux Journées Portes Ouvertes est validée"
  end

  def a_place_opened(participation)
    @user      = participation.user
    @planning  = participation.planning
    @course    = participation.course
    @structure = participation.course.structure
    mail to: @user.email, subject: "Votre inscription vient d'être prise en compte"
  end

  def welcome_to_waiting_list(participation)
    @user     = participation.user
    @planning = participation.planning
    @course   = participation.course
    @structure = participation.course.structure
    mail to: @user.email, subject: "Votre inscription en liste d'attente aux Journées Portes Ouvertes est validée"
  end

  def unsubscription(participation)
    @user     = participation.user
    @planning = participation.planning
    @course   = participation.course
    @structure = participation.course.structure
    mail to: @user.email, subject: "Votre désinscription a bien été prise en compte"
  end

  def alert_for_changes(participation)
    @user     = participation.user
    @planning = participation.planning
    @course   = participation.course
    # mail to: @user.email, subject: 'Change'
  end

  def alert_for_destroy(participation)
    @user     = participation.user
    @planning = participation.planning
    @course   = participation.course
    # mail to: @user.email, subject: 'Destroy'
  end
end
