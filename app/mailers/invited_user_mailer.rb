# encoding: utf-8
class InvitedUserMailer < ActionMailer::Base

  layout 'email'

  default from: "\"L'équipe de CoursAvenue.com\" <contact@coursavenue.com>"

  def recommand_friends(invited_user)
    @invited_user = invited_user
    @email_text   = invited_user.email_text
    @email        = invited_user.email
    @referrer     = invited_user.referrer
    mail to: @email,
         subject: "#{@referrer.name} vous invite à créer votre profil sur CoursAvenue.",
         template_name: "#{invited_user.type.split('::').last.downcase}/recommand_friends"
  end

  # TODO
  def inform_invitation_success(structure, invited_email)
    @structure     = structure
    @invited_email = invited_email
    @show_links    = true
    mail to: @structure.main_contact.email, subject: "Félicitations ! Votre parrainage a bien été pris en compte"
  end

  # TODO
  def send_invitation_stage_1(structure, invited_email)
    @structure     = structure
    @invited_email = invited_email
    mail to: invited_email, subject: "#{structure.name} vous invite à créer votre profil sur CoursAvenue."
  end

  # TODO
  def send_invitation_stage_2(structure, invited_email)
    @structure     = structure
    @invited_email = invited_email
    mail to: invited_email, subject: "#{structure.name} vous invite à créer votre profil sur CoursAvenue."
  end
end
