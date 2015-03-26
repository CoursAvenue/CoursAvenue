class Newsletter::MetricDecorator < Draper::Decorator
  delegate_all

  def opened_percentage
    return 0 if object.nb_email_sent.zero?
    ((object.nb_opening.to_f / object.nb_email_sent.to_f) * 100.0).round(1)
  end

  def click_percentage
    return 0 if object.nb_email_sent.zero?
    ((object.nb_click.to_f / object.nb_email_sent.to_f) * 100.0).round(1)
  end
end
