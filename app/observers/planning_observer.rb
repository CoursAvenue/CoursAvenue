class PlanningObserver < ActiveRecord::Observer

  def after_save(planning)
    planning.structure.update_synced_attributes
  end
end
