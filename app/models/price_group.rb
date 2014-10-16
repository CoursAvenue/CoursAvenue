class PriceGroup < ActiveRecord::Base
  acts_as_paranoid
  include I18n::Alchemy

  ######################################################################
  # Relations                                                          #
  ######################################################################
  has_many :courses
  has_many :prices

  belongs_to :structure, touch: true

  attr_accessible :structure, :name, :course_type, :details,
                  :prices_attributes, :premium_visible

  accepts_nested_attributes_for :prices,
                                 reject_if: :reject_price,
                                 allow_destroy: true


  ######################################################################
  # Validations                                                        #
  ######################################################################
  validates :name, :structure, presence: true
  validate :at_least_one_price

  ######################################################################
  # Callbacks                                                          #
  ######################################################################
  after_initialize :default_name
  after_save :touch_relations

  ######################################################################
  # Scopes                                                             #
  ######################################################################
  scope :for_regular_courses, -> { where( course_type: 'regular' ) }
  scope :for_trainings,       -> { where( course_type: 'training' ) }

  def for_regular_course?
    course_type == 'regular'
  end

  def for_training?
    course_type == 'training'
  end

  # Following methods use select instead of where to force retrieving prices even
  # if they are not persisted
  def book_tickets
    self.prices.select{ |p| p.type == 'Price::BookTicket' }.reject(&:blank?).sort_by(&:number)
  end

  def premium_offers
    self.prices.select{ |p| p.type == 'Price::PremiumOffer' }
  end

  def subscriptions
    self.prices.select{ |p| p.type == 'Price::Subscription' }.sort{ |p1, p2| Price::Subscription::TYPES_ORDER[p1.libelle] <=> Price::Subscription::TYPES_ORDER[p2.libelle] }
  end

  def registrations
    self.prices.select{ |p| p.type == 'Price::Registration' }
  end

  def discounts
    self.prices.select{ |p| p.type == 'Price::Discount' }
  end

  def trial
    self.prices.select{ |p| p.type == 'Price::Trial' }.first
  end

  # Tells wether or not the price_group has premium offers
  #
  # @return Boolean
  def has_premium_prices?
    return (premium_offers.any? or trial.present? or discounts.any? or book_tickets.map(&:promo_amount).compact.any?)
  end

  def offers_text
    offers = []
    offers << 'Essai gratuit'  if trial and trial.free?
    offers << 'Tarifs réduits' if discounts.any?
    offers << 'Promotions'     if premium_offers.any?
    offers
  end

  private

  def at_least_one_price
    if prices.empty?
      errors.add :base, "Ajoutez au moins un tarif"
    end
  end

  def default_name
    self.name ||= "Grille tarifaire #{self.structure.price_groups.count + 1}" if self.new_record? and self.structure
  end

  # Method for accepts_nested_attributes_for :prices
  # Tells if the price is valid regarding attributes passed
  # Check if the price is valid by checking its valid? method
  # @param  attributes Automatically passed by Rails
  #
  # @return Boolean
  def reject_price attributes
    exists = attributes[:id].present?
    _price = Price.new(attributes.merge(price_group: self))
    price_has_to_be_rejected  = _price.has_to_be_rejected? || attributes[:delete_price].present?
    # Destroy if price exists and amount is nil
    attributes.merge!({:_destroy => 1}) if exists and price_has_to_be_rejected
    # Reject if price does't not exist yet and amount is nil
    return (!exists and price_has_to_be_rejected)
  end

  def touch_relations
    self.courses.map(&:touch)
    self.prices.map(&:touch)
  end
end
