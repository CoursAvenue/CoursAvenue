class Course::Training < Course

  has_many :prices, foreign_key: 'course_id'

  accepts_nested_attributes_for :prices,
                                 reject_if: :reject_price,
                                 allow_destroy: true

  def is_training?
    true
  end

  def length
    if plannings.any?
      plannings.first.length
    else
      0
    end
  end

  def type_name
    'Stage'
  end

  def self.underscore_name
    'training'
  end

  def underscore_name
    self.class.underscore_name
  end

  def expired?
    return true if plannings.empty?
    (plannings.map(&:end_date).compact.sort.last || Date.yesterday) < Date.today
  end

  def can_be_published?
    plannings.future.any? and price_group.present?
  end

  def migrate_prices
    return if self.price_group.nil?
    self.price_group.prices.update_all(course_id: self.id, price_group_id: nil)

    # Deals with prices that are Premium Offers and Discounts
    (self.price_group.prices.premium_offers + self.price_group.prices.discounts).each do |price|
      if price.info.present?
        new_info = "#{I18n.t(price.libelle)} - #{price.info}"
      else
        new_info = I18n.t(price.libelle)
      end
      price.update_columns info: new_info, number: 1, type: 'Price::BookTicket', amount: price.promo_amount
    end
    # Deals with prices that are Registrations
    self.price_group.prices.registrations.update_all(type: 'Price::BookTicket', number: 1)

    self.price_group.destroy
  end
end
