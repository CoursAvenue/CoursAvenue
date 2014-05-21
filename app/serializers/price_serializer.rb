class PriceSerializer < ActiveModel::Serializer
  include PricesHelper

  attributes :libelle, :amount, :info, :promo_percentage, :promo_amount, :promo_amount_type

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
    readable_amount(object.amount) if object.amount
  end

  def promo_amount
    readable_amount(object.promo_amount) if object.promo_amount
  end

end
