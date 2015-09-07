# encoding: utf-8
class SuperAdminMailer < ActionMailer::Base
  include ::ActionMailerWithTextPart
  include Roadie::Rails::Automatic

  layout 'email'

  default from: 'CoursAvenue <hello@coursavenue.com>'
  default to:   'contact@coursavenue.com'

  def pass_sold(user)
    @user = user
    mail subject: "Pass vendu"
  end

  def inform_admin(subject, text)
    @text = text
    mail subject: subject
  end
  ######################################################################
  # END                                                                #
  ######################################################################

  def new_admin_has_signed_up(admin)
    @admin     = admin
    @structure = admin.structure
    mail to: 'inscription@coursavenue.com', subject: "Un prof vient de s'enregistrer !"
  end

  def subscription_plan_export_uploaded_to_s3(subscription_plan_export)
    @export_url = subscription_plan_export.url
    mail subject: "L'export des suivis premium est terminé"
  end

  def someone_tried_to_take_control_of_existing_structure(structure, email)
    @structure = structure
    @email     = email
    mail subject: "#{@email} a essayé de prendre le contrôle de #{@structure.name} en vain",
         to: 'kryqhl33@incoming.intercom.io'
  end

  def has_destroyed(structure)
    @structure = structure
    mail subject: "#{@structure.name} a supprimé son compte..."
  end

  def ask_for_deletion(comment)
    @comment   = comment
    @structure = @comment.structure
    mail subject: 'Un professeur demande une suppression de commentaire'
  end

  def alert_charge_disputed(structure, reason, status)
    @structure = structure
    @reason    = reason
    @status    = status

    mail subject: 'Un professeur a contesté un paiement'
  end

  def alert_charge_withdrawn(structure, reason, status)
    @structure = structure
    @reason    = reason
    @status    = status

    mail subject: 'Un retrait a eu lieu suite a une contestation de paiement'
  end

  def alert_charge_reinstated(structure, reason, status)
    @structure = structure
    @reason    = reason
    @status    = status

    mail subject: ''
  end

  def alert_for_non_answered_participation_request(participation_request)
    @participation_request = participation_request
    @structure             = participation_request.structure
    @user                  = participation_request.user
    @course                = participation_request.course
    if @participation_request.last_modified_by == 'Structure'
      subject =  "L'élève #{@user.full_name} n'a pas répondu"
    else
      subject = "Le prof #{@structure.name} n'a pas répondu"
    end
    mail to: 'kryqhl33@incoming.intercom.io',
         subject: subject
  end

  def alert_for_seven_days_trial(subscription)
    @structure = subscription.structure
    if subscription.plan.website_plan?
      subject = "J+7 période d'essai Site Internet"
    else
      subject = "J+7 période d'essai Modules"
    end
    mail to: 'kryqhl33@incoming.intercom.io',
         subject: subject
  end

  def alert_for_second_day_after_charged(subscription)
    @structure = subscription.structure
    if subscription.plan.website_plan?
      subject = "J+2 activation Site Internet"
    else
      subject = "J+2 activation Modules"
    end
    mail to: 'kryqhl33@incoming.intercom.io',
         subject: subject
  end

  def new_call_reminder_arrived(call_reminder)
    @call_reminder = call_reminder
    mail to: 'kryqhl33@incoming.intercom.io',
         subject: 'Demande de rappel'
  end

  def alert_for_disabling_structure(structure)
    @structure = structure
    mail to: 'kryqhl33@incoming.intercom.io',
      subject: "La structure #{structure.name} a été désactivée"
  end

  def alert_for_user_with_more_than_five_requests(user)
    @user = user
    mail subject: "L'utilsateur #{ @user.name } a fait plus de cinq réservations en une semaine"
  end
end
