class Newsletter::Subscription < ActiveRecord::Base
  belongs_to :mailing_list, class: 'Newsletter::MailingList'
  belongs_to :user_profile

  # The email address of the subscription.
  #
  # @return a String.
  def email
    user_profile.email
  end

  # Unsubscribe from the mailing list and send confirmation.
  #
  # @return nothing.
  def unsubscribe!
    subscribed = false
    NewsletterMailer.delay.confirm_unsubscribtion(self)

    save
  end
end
