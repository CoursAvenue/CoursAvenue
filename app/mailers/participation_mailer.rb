# encoding: utf-8
class ParticipationMailer < ActionMailer::Base
  helper :plannings, :levels

  layout 'email'

  default from: "\"L'équipe de CoursAvenue.com\" <contact@coursavenue.com>"

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
    @user      = participation.user
    @planning  = participation.planning
    @course    = participation.course
    @structure = participation.course.structure
    mail to: @structure.main_contact.email, subject: "Un élève vient de s'inscrire à vos Portes Ouvertes"
  end

  # When a student subscribe to a waiting list
  # @param  participation
  #
  # @return nil
  def user_subscribed_to_waiting_list(participation)
    @user      = participation.user
    @planning  = participation.planning
    @course    = participation.course
    @structure = participation.course.structure
    mail to: @structure.main_contact.email, subject: "Un élève vient de s'inscrire sur liste d'attente à vos Portes Ouvertes"
  end

  # When a student unsubscribe
  # @param  participation
  #
  # @return nil
  def unsubscription_for_teacher(participation)
    @user      = participation.user
    @planning  = participation.planning
    @course    = participation.course
    @structure = participation.course.structure
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
    mail to: @user.email, subject: "Invitez vos proches à s'inscrire à votre atelier Portes Ouvertes"
  end


  # When a user participate to a planning
  # @param  participation
  #
  # @return nil
  def welcome(participation)
    @user      = participation.user
    @planning  = participation.planning
    @course    = participation.course
    @structure = participation.course.structure
    mail to: @user.email, subject: "Votre inscription aux Journées Portes Ouvertes est validée"
  end

  # When a user participate and appears on a waiting
  # @param  participation
  #
  # @return nil
  def welcome_to_waiting_list(participation)
    @user     = participation.user
    @planning = participation.planning
    @course   = participation.course
    @structure = participation.course.structure
    mail to: @user.email, subject: "Votre inscription en liste d'attente aux Journées Portes Ouvertes est validée"
  end

  # When a user was on a waiting list and a place opened
  # @param  participation
  #
  # @return nil
  def a_place_opened(participation)
    @user      = participation.user
    @planning  = participation.planning
    @course    = participation.course
    @structure = participation.course.structure
    mail to: @user.email, subject: "Votre inscription vient d'être prise en compte"
  end

  # When a user unsubscribe
  # @param  participation
  #
  # @return nil
  def unsubscription(participation)
    @user     = participation.user
    @planning = participation.planning
    @course   = participation.course
    @structure = participation.course.structure
    mail to: @user.email, subject: "Votre désinscription a bien été prise en compte"
  end

  def inform_invitation_success_for_jpo(inviter, invited_user, participation)
    @user          = inviter
    @invited_user  = invited_user
    @participation = participation
    @planning      = participation.planning
    mail to: @user.email, subject: "Félicitations ! L'un de vos proches s'est inscrit aux Portes Ouvertes"
  end
end
