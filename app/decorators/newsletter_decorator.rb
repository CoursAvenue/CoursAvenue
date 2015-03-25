class NewsletterDecorator < Draper::Decorator
  delegate_all

  def status
    if object.state == 'sent'
      "envoyée le #{I18n.l(object.sent_at, format: :long_human)}"
    elsif object.state == 'sending'
      "En cours d'envoi"
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
    if object.state == 'sent'
      'Envoyé'
    elsif object.state == 'sending'
      "En cours d'envoi"
    else
      'Brouillon'
    end
  end

  def recipient_count
    object.mailing_list.recipient_count
  end
end
