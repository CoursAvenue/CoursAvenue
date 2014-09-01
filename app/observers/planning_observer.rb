class PlanningObserver < ActiveRecord::Observer

  def after_save(planning)
    planning.course.structure.update_meta_datas
    # planning.participations.map(&:alert_for_changes)
  end

  def after_destroy(planning)
    # planning.participations.map(&:alert_for_destroy)
  end
end
