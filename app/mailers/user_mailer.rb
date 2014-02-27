# encoding: utf-8
class UserMailer < ActionMailer::Base
  layout 'email'

  helper :prices, :comments

  default from: "\"L'équipe de CoursAvenue.com\" <contact@coursavenue.com>"


  ######################################################################
  # Email reminder                                                     #
  ######################################################################
  # Monday email to push the user to fill passions
  def passions_incomplete(user)
    @user    = user
    mail to: @user.email, subject: 'Renseignez toutes vos passions sur votre profil'
  end

  # Welcomes the user on the platforme
  def contact(name, email, content)
    @name    = name
    @email   = email
    @content = content
    mail to: 'contact@coursavenue.com', subject: 'Message de contact'
  end

  def welcome(user)
    @user = user
    mail to: @user.email, subject: 'Bienvenue sur CoursAvenue.com'
  end

  # Inform the user that the comment has correctly been submitted
  def congratulate_for_accepted_comment(comment)
    @comment   = comment
    @structure = @comment.structure
    mail to: @comment.email, subject: "Votre avis à propos de : #{@structure.name}"
  end

  def congratulate_for_comment(comment)
    @comment   = comment
    @structure = @comment.structure
    mail to: @comment.email, subject: "Votre avis à propos de : #{@structure.name}"
  end

  # Inform the user that the comment has been validated by the teacher
  def comment_has_been_validated(comment)
    @comment   = comment
    @structure = @comment.structure
    mail to: @comment.email, subject: "Votre avis à été validé !"
  end

  # Gives user information on establishment
  def alert_user_for_reservation(reservation)
    @reservation = reservation
    @structure   = @reservation.structure
    @user        = reservation.user

    mail to: @user.email,               subject: @reservation.email_subject_for_user
    mail to: 'nim.izadi@gmail.com',     subject: @reservation.email_subject_for_user if Rails.env.development?
  end

  # Inform establishment that someone wants to reserve a course
  def alert_structure_for_reservation(reservation)
    @reservation = reservation
    @user        = reservation.user
    @structure   = @reservation.structure

    mail to: @structure.contact_email, subject: @reservation.email_subject_for_structure
  end

  # -----------------
  # For inactive users
  # -----------------

  def recommend_structure(structure_name, structure_email, recommendation)
    @structure_name  = structure_name
    @structure_email = structure_email
    @recommendation  = recommendation
    mail to: 'contact@coursavenue.com', subject: "Un élève vient de recommander un professeur"
  end

  def ask_for_feedbacks(structure, email_text, email)
    @structure  = structure
    @email      = email
    user_email  = email
    @user       = User.where{email == user_email}.first
    @email_text = email_text
    mail to: email, subject: "#{structure.name} vous demande une recommandation"
  end

  def ask_for_feedbacks_stage_1(structure, email)
    @structure = structure
    @email     = email
    user_email  = email
    @user       = User.where{email == user_email}.first
    mail to: email, subject: "Votre opinion sur #{structure.name}"
  end

  def ask_for_feedbacks_stage_2(structure, email)
    @structure = structure
    @email     = email
    user_email  = email
    @user       = User.where{email == user_email}.first
    mail to: email, subject: "#{structure.name} vous demande une recommandation"
  end

  def ask_for_feedbacks_stage_3(structure, email)
    @structure = structure
    @email     = email
    user_email  = email
    @user       = User.where{email == user_email}.first
    mail to: email, subject: "#{structure.name} vous demande une recommandation"
  end

  # -----------------
  # Recommandations
  # -----------------

  def recommand_friends(structure, email_text, email)
    @structure  = structure
    @email_text = email_text
    @email      = email
    mail to: email, subject: "#{structure.name} vous invite à créer votre profil sur CoursAvenue."
  end

end
