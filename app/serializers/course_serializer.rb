class CourseSerializer < ActiveModel::Serializer

  cached
  def cache_key
    'CourseSerializer/' + object.cache_key + '/v6'
  end

  attributes :id, :name, :description, :db_type, :structure_id, :structure_slug,
             :is_individual, :is_lesson, :frequency, :on_appointment,
             :is_open_for_trial, :min_price_amount, :no_trial, :indexable_card_slug,
             :teaches_at_home, :accepts_payment, :start_date, :end_date, :structure_is_active,
             :cant_be_joined_during_year

  has_many :plannings,           serializer: PlanningSerializer
  has_many :price_group_prices,  serializer: PriceSerializer
  has_many :child_subjects,      serializer: SubjectListSerializer

  def price_group_prices
    if object.is_training? and object.prices.length > 1
      object.prices.order('amount ASC')
    else
      object.price_group_prices.order('amount ASC')
    end
  end

  def min_price_amount
    if object.prices.any?
      price = object.prices.order('promo_amount ASC, amount ASC').first
      [price.amount, price.promo_amount].compact.min
    end
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
    (object.structure.active? && object.structure.enabled? && !object.structure.is_sleeping?)
  end

  def structure_slug
    object.structure.slug
  end

  def indexable_card_slug
    object.indexable_cards.sample.slug if object.indexable_cards.any?
  end
end
