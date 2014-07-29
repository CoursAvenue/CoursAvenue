class PriceSerializer < ActiveModel::Serializer
  include PricesHelper

  attributes :libelle, :amount, :info, :promo_percentage, :promo_amount, :promo_amount_type, :libelle_type, :is_free

  def libelle_type
    case object.type
    when 'Price::Trial'
      'Spéciale découverte'
    when 'Price::PremiumOffer'
      'Offre spéciale'
    when 'Price::Discount'
      'Tarif réduit'
    else
      'Tarif normal'
    end
  end

  def info
    if object.discount? and object.libelle != 'prices.discount.other'
      str = "Pour les "
      str << I18n.t("#{object.libelle}_plural")
      str << ". #{object.info}" if object.info.present?
    else
      object.info
    end
  end

  def libelle
    case object.type
    when 'Price::BookTicket'
      if object.number == 1
        '1 cours'
      else
        "Carnet de #{object.number} tickets"
      end
    else
      I18n.t(object.libelle) if object.libelle
    end
  end

  def amount
    "#{readable_amount(object.amount)}" if object.amount
  end

  def is_free
    return (object.amount.nil? or object.amount == 0)
  end

  def promo_amount
    "#{readable_amount(object.promo_amount, false, (object.promo_amount_type || '€'))}" if object.promo_amount
  end

end
