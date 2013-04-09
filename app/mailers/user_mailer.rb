# encoding: utf-8
class UserMailer < ActionMailer::Base
  default from: "\"L'équipe de CoursAvenue.com\" <contact@coursavenue.com>"

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.user_mailer.book_class.subject
  #

  def alert_user_for_reservation(reservation)
    @reservation = reservation
    @place       = @reservation.place

    mail to: @reservation.email, subject: @reservation.email_subject_for_user
    mail to: 'contact@coursavenue.com', subject: @reservation.email_subject_for_user unless Rails.env.development?
    mail to: 'nim.izadi@gmail.com', subject: @reservation.email_subject_for_user
  end

  def alert_structure_for_reservation(reservation)
    @reservation = reservation
    @place       = @reservation.place

    if Rails.env.production?
      mail to: @place.contact_email, subject: @reservation.email_subject_for_structure
    else
      mail to: 'nima@coursavenue.com', subject: @reservation.email_subject_for_structure
    end
  end
end
