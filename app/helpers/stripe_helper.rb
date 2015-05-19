module StripeHelper
  # The dashboard URL depending on the environment we're in.
  #
  # @return a String.
  def stripe_dashboard_url
    if Rails.env.production?
      'https://dashboard.stripe.com'
    else
      'https://dashboard.stripe.com/test'
    end
  end
end
