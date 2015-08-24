class CourseSerializer < ActiveModel::Serializer

  cached
  def cache_key
    'CourseSerializer/' + object.cache_key
  end

  attributes :id, :name, :description, :db_type, :structure_id,
             :is_individual, :is_lesson, :frequency, :on_appointment,
             :is_open_for_trial, :min_price_amount,
             :teaches_at_home, :accepts_payment, :start_date, :end_date, :structure_is_active

  has_many :plannings,           serializer: PlanningSerializer
  has_many :price_group_prices,  serializer: PriceSerializer
  has_many :child_subjects,      serializer: SubjectListSerializer

  def min_price_amount
    object.prices.order('amount ASC').first.amount if object.prices.any?
  end

  def plannings
    object.plannings.future.ordered_by_day
  end

  def child_subjects
    object.subjects.at_depth(2)
  end

  def is_individual
    object.is_individual?
  end

  def db_type
    object.type
  end

  def is_lesson
    object.is_lesson?
  end

  def frequency
    I18n.t(object.frequency) if object.frequency.present?
  end

  def levels
    join_levels_text(object) if object.is_private?
  end

  def audiences
    join_audiences(object) if object.is_private?
  end

  def structure_is_active
    object.structure.active? && !object.structure.is_sleeping?
  end
end
