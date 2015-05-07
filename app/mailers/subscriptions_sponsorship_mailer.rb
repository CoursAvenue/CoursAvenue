class SubscriptionsSponsorshipMailer < ActionMailer::Base
  include ::ActionMailerWithTextPart
  include Roadie::Rails::Automatic

  layout 'email'
  helper :application

  default from: 'CoursAvenue <noreply@coursavenue.com>'

  def sponsor_user(sponsorship, custom_message = nil)
    @sponsorship = sponsorship
    @structure   = sponsorship.subscription.structure

    mail to: sponsorship.sponsored_email,
      subject: "#{sponsorship.subscription.structure} veut vous parrainer !"
  end
end
