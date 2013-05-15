# encoding: utf-8
class AdminMailer < ActionMailer::Base
  default from: "\"L'équipe de CoursAvenue.com\" <contact@coursavenue.com>"

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.user_mailer.book_class.subject
  #

  def send_feedbacks(structure, email)
    @structure = structure
    mail to: email, subject: "Un petit coup de pouce !", from: @structure.email_address
  end

  def admin_validated(admin)
    @admin = admin
    mail to: @admin.email, subject: 'Votre compte a été validé'
  end

  def new_admin_has_signed_up(admin)
    @admin = admin
    if Rails.env.development?
      mail to: 'nim.izadi@gmail.com', subject: "Un prof vient de s'enregistrer !"
    else
      mail to: 'contact@coursavenue.com', subject: "Un prof vient de s'enregistrer !"
    end
  end
end
