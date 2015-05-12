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

  ######################################################################
  # For premium users                                                  #
  ######################################################################
  def someone_canceled_his_subscription(subscription_plan)
    @structure         = subscription_plan.structure
    @subscription_plan = subscription_plan
    mail subject: "#{@structure.name} a résilié son abonnement"
  end

  def someone_reactivated_his_subscription(subscription_plan)
    @structure         = subscription_plan.structure
    @subscription_plan = subscription_plan
    mail subject: "#{@structure.name} a réactivé son abonnement"
  end

  # Sent for admin
  def go_premium structure, offer
    @structure = structure
    @offer     = offer
    mail subject: 'Un professeur est passé premium'
  end

  def go_premium_fail structure, params
    @structure = structure
    @params    = params
    mail to: 'nima@coursavenue.com', subject: 'Un professeur voulait passer premium mais a échoué'
  end

  def be2bill_transaction_notifications structure, params
    @structure = structure
    @params    = params
    mail to: 'nima@coursavenue.com', subject: 'Be2Bill transaction notifiaction'
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
    mail subject: 'Un professeur a contesté un paiement'
  end

  def alert_charge_withdrawn(structure, reason, status)
    mail subject: 'Un retrait a eu lieu suite a une contestation de paiement'
  end

  def alert_charge_reinstated(structure, reason, status)
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
end
