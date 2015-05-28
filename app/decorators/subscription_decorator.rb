class SubscriptionDecorator < Draper::Decorator
  delegate_all

  def frequency
    "tous les #{object.plan.interval == 'month' ? 'mois' : 'ans'}"
  end

  def plan_name
    object.plan.public_name
  end

  def structure_name
    object.structure.name
  end

  def next_frequency
    if object.plan.interval == 'month'
      'Le mois suivant'
    else
      "L'année suivante"
    end
  end

  def remaining_trial_days
    (object.trial_ends_at.to_date - Date.today).to_i
  end
end
