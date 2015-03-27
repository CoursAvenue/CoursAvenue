class Course::Lesson < Course

  has_many :prices, -> { where(type: 'Price::Trial').limit(1) }, foreign_key: 'course_id'

  accepts_nested_attributes_for :prices,
                                 reject_if: :reject_price,
                                 allow_destroy: true

  def is_lesson?
    true
  end

  def type_name
    'Cours collectif'
  end

  def self.underscore_name
    'lesson'
  end

  def underscore_name
    self.class.underscore_name
  end

  def expired?
    return false
  end

  def migrate_prices
    if self.price_group and self.price_group.prices.any?
      if self.price_group.prices.trials.any?
        self.price_group.prices.trials.update_all course_id: self.id, price_group_id: nil
      else
        self.prices.create amount: (self.price_group.prices.order('amount ASC NULLS LAST').first.amount || 0),
                             type: 'Price::Trial'
      end
    else
      self.prices.create amount: 0, type: 'Price::Trial'
    end
  end
end
