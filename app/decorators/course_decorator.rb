class CourseDecorator < Draper::Decorator
  include PricesHelper
  delegate_all

  # Description and price of the first course that the user wants to attempt
  #
  # @return
  # Essai gratuit
  # Séance d'essai : 15€
  # Une séance : 18€
  # Stage : 67€
  # Si aucun de tout ça, mettre "Séance d'essai"
  def first_session_detail
    if is_open_for_trial?
      "Essai gratuit"
    elsif price_group.trial
      "Séance d'essai : #{readable_amount(price_group.trial.amount)}"
    elsif is_training?
      "Stage : #{readable_amount(price_group.min_price_amount)}"
    elsif price_group.trial.nil?
      "Une séance : #{readable_amount(price_group.min_price_amount)}"
    end
  end

end
