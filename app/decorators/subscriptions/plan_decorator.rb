class Subscriptions::PlanDecorator < Draper::Decorator
  delegate_all

  # Get the price in the format "xx € / mois".
  def price
    "#{ object.amount }€ #{ by_interval }"
  end

  # Get the interval in the format "/ mois".
  def by_interval
    "/ #{object.interval == "month" ? 'mois' : 'an'}"
  end
end
