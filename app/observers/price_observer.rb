class PlanningObserver < ActiveRecord::Observer

  def after_save(price)
    price.structure.update_synced_attributes
  end
end
