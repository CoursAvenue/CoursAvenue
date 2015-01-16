class CourseDecorator < Draper::Decorator
  include PricesHelper
  delegate_all

  # [first_session_detail description]
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
      "Stage : #{price_group}€"
    elsif price_group.trial.nil?
      "Une séance : #{readable_amount(price_group.trial.amount)}"
    end
  end
end
