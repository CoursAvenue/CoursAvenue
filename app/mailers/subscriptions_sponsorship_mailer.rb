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
      subject: "#{ sponsorship.subscription.structure.name } veut vous parrainer !"
  end

  def subscription_reedeemed(sponsorship)
    @sponsorship  = sponsorship
    @subscription = sponsorship.subscription
    @structure    = sponsorship.subscription.structure
    @plan         = @subscription.plan

    mail to: @structure.email,
      subject: "Vous venez d'être crédité d'un mois gratuit d'abonnement #{ @plan.public_name }"
  end
end
