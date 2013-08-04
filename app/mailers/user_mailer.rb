# encoding: utf-8
class UserMailer < ActionMailer::Base
  layout 'email'

  helper :prices, :comments

  default from: "\"L'équipe de CoursAvenue.com\" <contact@coursavenue.com>"

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.user_mailer.book_class.subject
  #

  # Welcomes the user on the platforme
  def welcome(user)
    @user = user
    mail to: @user.email, subject: 'Bienvenue sur CoursAvenue.com'
  end

  # Inform the user that the comment has correctly been posted
  def after_comment(comment)
    @comment   = comment
    @structure = @comment.structure
    mail to: @comment.email, subject: "Votre avis à propos de : #{@structure.name}"
  end

  # Inform teacher that a students has commented his establishment
  def after_comment_for_teacher(comment)
    @comment = comment
    @structure = @comment.structure
    mail to: @comment.commentable.contact_email, subject: 'Un élève vient de poster un commentaire sur votre profil public CoursAvenue.com'
  end

  # Gives user information on establishment
  def alert_user_for_reservation(reservation)
    @reservation = reservation
    @place       = @reservation.place
    @user        = reservation.user
    @structure   = @place.structure

    mail to: @user.email,               subject: @reservation.email_subject_for_user
    mail to: 'nim.izadi@gmail.com',     subject: @reservation.email_subject_for_user if Rails.env.development?
  end

  # Inform establishment that someone wants to reserve a course
  def alert_structure_for_reservation(reservation)
    @reservation = reservation
    @user        = reservation.user
    @place       = @reservation.place
    @structure   = @place.structure

    if Rails.env.production?
      mail to: @place.contact_email, subject: @reservation.email_subject_for_structure
    end
  end

  private
end
