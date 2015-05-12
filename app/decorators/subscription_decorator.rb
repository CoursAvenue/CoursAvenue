class SubscriptionDecorator < Draper::Decorator
  delegate_all

  def frequency
    "tous les #{object.plan.interval == 'month' ? 'mois' : 'ans'}"
  end

  def remaining_trial_days
    (object.trial_end.to_date - Date.today).to_i
  end
end
