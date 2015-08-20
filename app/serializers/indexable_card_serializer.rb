class IndexableCardSerializer < ActiveModel::Serializer

  cached
  delegate :cache_key, to: :object

  attributes :id, :structure_is_active, :db_type, :teaches_at_home,
              :on_appointment, :frequency, :cant_be_joined_during_year,
              :no_class_during_holidays, :min_price

  has_many :plannings, serializer: PlanningSerializer

  def plannings
    object.plannings.future.ordered_by_day
  end

  def min_price
    PriceSerializer.new(object.course.prices.order('amount ASC').first) if object.course.prices.any?
  end

  def structure_is_active
    object.structure.active? && !object.structure.is_sleeping?
  end

  def db_type
    object.course.type
  end

  def teaches_at_home
    object.course.teaches_at_home
  end

  def on_appointment
    object.course.on_appointment
  end

  def frequency
    I18n.t(object.course.frequency) if object.course.frequency.present?
  end

  def cant_be_joined_during_year
    object.course.cant_be_joined_during_year
  end

  def no_class_during_holidays
    object.course.no_class_during_holidays
  end

end
