class CourseDecorator < Draper::Decorator
  include PricesHelper
  delegate_all

  # Description and price of the first course that the user wants to attempt
  #
  # @return
  #    Essai gratuit
  #    Séance d'essai : 15€
  #    Une séance : 18€
  #    Stage : 67€
  def first_session_detail(with_popover=false)
    return "Essai gratuit" if is_open_for_trial?
    return "Séance d'essai" if price_group.nil?
    detail_html = ''
    if with_popover
      detail_html << "<span class='has-tooltip'"
      detail_html << "data-content=\"#{I18n.t('tooltips.users.pay_to_teacher_html')}\""
      detail_html << "data-toggle='popover'"
      detail_html << "data-html='true' data-placement='top' data-trigger='hover'>"
    end
    if price_group.trial
      detail_html << "Séance d'essai : #{readable_amount(price_group.trial.amount)}"
    elsif is_training?
      detail_html << "Stage : #{readable_amount(price_group.min_price_amount)}"
    elsif price_group.trial.nil?
      detail_html << "Une séance : #{readable_amount(price_group.min_price_amount)}"
    end
    detail_html.html_safe
  end

end
