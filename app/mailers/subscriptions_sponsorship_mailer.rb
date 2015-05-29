class SubscriptionsSponsorshipMailer < ActionMailer::Base
  include ::ActionMailerWithTextPart
  include Roadie::Rails::Automatic

  layout 'email'
  helper :application

  default from: 'CoursAvenue <noreply@coursavenue.com>'

  def sponsor_user(sponsorship, message = nil)
    @message     = message
    @sponsorship = sponsorship
    @structure   = sponsorship.subscription.structure

    mail to: sponsorship.sponsored_email,
      subject: "#{ sponsorship.subscription.structure.name } vous offre 1 mois gratuit sur CoursAvenue"
  end

  def subscription_reedeemed(sponsorship)
    @sponsorship         = sponsorship
    @subscription        = sponsorship.subscription
    @structure           = sponsorship.subscription.structure
    @redeeming_structure = sponsorship.redeeming_structure
    @plan                = @subscription.plan

    mail to: @structure.email,
      subject: "Félicitations ! Votre parrainage a bien été pris en compte"
  end
end
