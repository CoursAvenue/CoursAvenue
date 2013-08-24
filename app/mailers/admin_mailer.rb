# encoding: utf-8
class AdminMailer < ActionMailer::Base
  layout 'email'

  default from: "\"L'équipe de CoursAvenue.com\" <contact@coursavenue.com>"

  def recommand_friends(structure, email_text, email)
    @structure  = structure
    @email_text = email_text
    @email      = email
    mail to: email, subject: "#{structure.name} vous invite à mettre en avant la qualité de vos cours"
  end

  def admin_validated(admin)
    @admin = admin
    mail to: @admin.email, subject: 'Votre compte a été validé'
  end

  def new_admin_has_signed_up(admin)
    @admin     = admin
    @structure = admin.structure
    if Rails.env.development?
      mail to: 'nim.izadi@gmail.com', subject: "Un prof vient de s'enregistrer !"
    else
      mail to: 'all@coursavenue.com', subject: "Un prof vient de s'enregistrer !"
    end
  end
end
