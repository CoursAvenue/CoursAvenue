# encoding: utf-8
class Place::Home < Place

  ######################################################################
  # Validations                                                        #
  ######################################################################
  validates :city     , presence: true
  validates :zip_code , presence: true, numericality: { only_integer: true }
  validates :radius   , presence: true, numericality: { only_integer: true }

  def name
    I18n.t('places.home.name')
  end

  def street
    I18n.t('places.home.street', zip_code: zip_code, city_name: city.name, radius: radius)
  end

  def address
    street
  end

  def is_home?
    true
  end
end
