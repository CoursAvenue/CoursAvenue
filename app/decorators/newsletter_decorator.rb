class NewsletterDecorator < Draper::Decorator
  delegate_all

  def status
    if object.sent?
      "envoyée le #{I18n.l(object.sent_at, format: :long_human)}"
    else
      "brouillon enregistré le #{I18n.l(object.updated_at, format: :long_human)}"
    end
  end

  def mailing_list
    if object.mailing_list.present?
      object.mailing_list.name
    else
      "Pas encore choisie"
    end
  end

  def badge
    object.sent? ? 'Envoyé' : 'Brouillon'
  end
end
