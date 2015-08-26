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
    return "1ère séance" if object.no_trial?
    return "Essai gratuit" if is_open_for_trial?
    return "Séance d'essai" if price_group.nil?
    detail_html = ''
    if with_popover
      detail_html << "<span class='has-tooltip'"
      detail_html << "data-content=\"#{I18n.t('tooltips.users.pay_to_teacher_html')}\""
      detail_html << "data-toggle='popover'"
      detail_html << "data-html='true' data-placement='top' data-trigger='hover'>"
    end
    if object.prices.trials.any?
      detail_html << "Séance d'essai : #{readable_amount(object.prices.trials.first.amount)}"
    elsif is_training?
      detail_html << "Stage : #{readable_amount(price_group.min_price_amount)}"
    elsif price_group.trial.nil?
      detail_html << "Une séance : #{readable_amount(price_group.min_price_amount)}"
    end
    detail_html.html_safe
  end

  def trial_price
    return nil if object.prices.trials.empty?
    trial = object.prices.trials.first
    "<strong class='push-half--right'>#{readable_amount(trial.amount)}</strong>".html_safe
  end

  def min_price
    object.prices.order('amount ASC').first if object.prices.any?
  end

  def training_prices
    return nil if object.prices.empty?
    prices_content = object.prices.map do |price|
      popover = ''
      popover = " <i class=\"v-middle fa-info cursor-help\" data-behavior=\"popover\" data-content=\"#{price.info}\"></i>" if price.info.present?
      if price.promo_amount?
        content = "<strong class='v-middle line-through'>#{readable_amount(price.amount)}</strong> #{readable_amount(price.promo_amount)}" + popover
      else
        content = "<strong class='v-middle'>#{readable_amount(price.amount)}" + "</strong>" + popover
      end
      "<div class=\"inline-block v-middle push-half--right\">#{content}</div>"
    end.join(' ')
    "<div class=\"inline-block v-middle\">#{prices_content}</div>".html_safe
  end

end
