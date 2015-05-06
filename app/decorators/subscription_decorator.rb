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
end
