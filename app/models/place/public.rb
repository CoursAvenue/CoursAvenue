# encoding: utf-8
class Place::Public < Place

  ######################################################################
  # Validations                                                        #
  ######################################################################
  validates :structure, :name, :street, :zip_code, :city_id , presence: true
  validates :zip_code, numericality: { only_integer: true }

end
