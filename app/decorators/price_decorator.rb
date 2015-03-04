class PriceDecorator < Draper::Decorator
  include PricesHelper

  # Description and price of the first course that the user wants to attempt
  #
  # @return
  #    Essai gratuit
  #    Séance d'essai : 15€
  #    Une séance : 18€
  #    Stage : 67€
  def details
    return "Essai gratuit" if object.trial? and object.free?
    detail_html = ''
    detail_html << "#{object.localized_libelle} : #{readable_amount(object.amount)}"
    detail_html.html_safe
  end

end
