class Subscriptions::PlanDecorator < Draper::Decorator
  delegate_all

  def price
    "#{object.amount.to_f / 100} €"
  end
end
