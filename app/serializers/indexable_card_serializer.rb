class IndexableCardSerializer < ActiveModel::Serializer

  cached
  def cache_key
    'IndexableCardSerializer/' + object.cache_key + '/v8/' + price_group_prices.maximum(:updated_at).to_i.to_s
  end

  attributes :id, :structure_is_active, :structure_slug, :db_type, :teaches_at_home,
              :on_appointment, :frequency, :cant_be_joined_during_year,
              :no_class_during_holidays, :min_price, :min_price_amount,
              :no_trial, :dominant_root_subject_vp_slug

  has_many :plannings, serializer: PlanningSerializer
  has_many :price_group_prices,  serializer: PriceSerializer

  def price_group_prices
    if object.course
      if object.course.is_training? and object.course.prices.length > 1
        object.course.prices.order('amount ASC')
      else
        object.course.price_group_prices.order('amount ASC')
      end
    end
  end

  def plannings
    object.plannings.future.ordered_by_day
  end

  def min_price
    PriceSerializer.new(object.course.prices.order('amount ASC').first) if object.course and object.course.prices.any?
  end

  def min_price_amount
    if object.course and object.course.prices.any?
      price = object.course.prices.order('promo_amount ASC, amount ASC').first
      [price.amount, price.promo_amount].compact.min
    end
  end

  def structure_is_active
    object.structure.enabled? && !object.structure.is_sleeping?
  end

  def db_type
    object.course.type if object.course
  end

  def teaches_at_home
    object.course.teaches_at_home if object.course
  end

  def on_appointment
    object.course.on_appointment if object.course
  end

  def frequency
    I18n.t(object.course.frequency) if object.course and object.course.frequency.present?
  end

  def cant_be_joined_during_year
    object.course.cant_be_joined_during_year if object.course
  end

  def no_class_during_holidays
    object.course.no_class_during_holidays if object.course
  end

  def structure_slug
    object.structure.slug
  end

  def dominant_root_subject_vp_slug
    object.course.dominant_root_subject.vertical_pages.first.slug
  end
end
