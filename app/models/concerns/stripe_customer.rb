module Concerns
  module StripeCustomer
    extend ActiveSupport::Concern

    included do
      # TODO: DRY this method in a StripeCustomer concern.
      # Retrieve the Stripe customer associated with this user.
      #
      # @return a Stripe::Customer or nil
      def stripe_customer
        return nil if self.stripe_customer_id.nil?

        Stripe::Customer.retrieve(self.stripe_customer_id)
      end

      # Create a new Stripe customer.
      # The stripe customer is the stripe account used for the subscription with CoursAvenue.
      #
      # @param token The card token gotten from the Stripe.js.
      #
      # @return a Stripe::Customer or nil
      def create_stripe_customer(token)
        return nil if token.nil?

        if self.class.to_s == 'Structure'
          description = "Compte client pour la structure #{ name } (id = #{ id })"
        else
          description = "Compte client pour l'utilisateur #{ name } (id = #{ id })"
        end

        stripe_customer = Stripe::Customer.create({
          description: description,
          source: token
        })

        self.stripe_customer_id = stripe_customer.id
        self.save

        stripe_customer
      end

    end
  end
end
