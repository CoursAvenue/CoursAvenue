class Structure::IndexableLock < ActiveRecord::Base
  # The purpose of this model is to not have the locked attribute in the struture model and
  # therefore avoiding calling the structure callback when locking / unlocking.
  belongs_to :structure
  validate :locked, presence: true
  validate :structure, presence: true

  scope :locked,   -> { where(locked: true) }
  scope :unlocked, -> { where(locked: false) }

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
