class CrmLock < ActiveRecord::Base
  # This model is locked when a call to the CRM is scheduled, and unlocked when the call is done.

  belongs_to :structure

  validate :locked, presence: true
  validate :structure, presence: true

  def lock!
    return if locked?

    self.locked = true
    self.locked_at = Time.current
    save
  end

  def unlock!
    return unless locked?

    self.locked = false
    save
  end
end
