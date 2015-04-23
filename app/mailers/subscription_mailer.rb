class SubscriptionMailer < ActionMailer::Base
  include ::ActionMailerWithTextPart
  include Roadie::Rails::Automatic

  layout 'email'
  helper :application

  default from: 'CoursAvenue <noreply@coursavenue.com>'

  def invoice_creation_notification(invoice)
    decorated_invoice = invoice.decorate
    mail to: "#{decorated_invoice.structure_name} noreply@coursavenue.com",
      subject: 'coucou'
  end

  def trial_will_end(subscription, structure)
    mail to:   structure.contact_email,
      subject: "La période d'essai de votre abonnement arrive à sa fin"
  end

  def subscription_canceled(structure, subscription)
    mail to: structure.contact_email,
      subject: 'Votre abonnement a été annulé'
  end
end
