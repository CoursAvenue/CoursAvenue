class Pro::StripeWebhookController < ApplicationController
  def create
    @event = Stripe::Event.retrieve(params[:id])
    StripeEvent.process!(@event) unless StripeEvent.processed?(@event)

    head :ok
  end
end
