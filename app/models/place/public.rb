# encoding: utf-8
class Place::Public < Place

  ######################################################################
  # Validations                                                        #
  ######################################################################
  validates :structure, presence: true
  validates :name     , presence: true
  validates :street   , presence: true
  validates :city     , presence: true
  validates :zip_code , presence: true, numericality: { only_integer: true }

end
