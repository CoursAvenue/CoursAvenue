class UserMailer < ActionMailer::Base
  default from: "contact@leboncours.com"

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.user_mailer.book_class.subject
  #
  def make_reservation(reservation)
    @reservation = reservation

    mail to: reservation.email, subject: @reservation.email_subject
    mail to: 'contact@leboncours.com', subject: @reservation.email_subject
    mail to: 'nim.izadi@gmail.com', subject: @reservation.email_subject
  end
end
