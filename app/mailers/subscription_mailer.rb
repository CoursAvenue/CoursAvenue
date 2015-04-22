class SubscriptionMailer < ActionMailer::Base
  include ::ActionMailerWithTextPart
  include Roadie::Rails::Automatic

  layout 'email'
  helper :application

  def invoice_creation_notification(invoice)
    decorated_invoice = invoice.decorate
    mail to: "#{decorated_invoice.structure_name} noreply@coursavenue.com",
      subject: 'coucou'
  end
end
