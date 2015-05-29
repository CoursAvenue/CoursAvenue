class StripeWebhookController < ApplicationController
  protect_from_forgery except: :create

  def create
    if params[:id].present?
      @event = Stripe::Event.retrieve(params[:id])
      StripeEvent.process!(@event) unless StripeEvent.processed?(@event)

      head :ok
    else
      head :bad_request
    end
  end
end
