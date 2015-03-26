class NewsletterDecorator < Draper::Decorator
  delegate_all

  def status
    if object.state == 'sent'
      "envoyée le #{I18n.l(local_time(object.sent_at), format: :long_human)}"
    elsif object.state == 'sending'
      "En cours d'envoi"
    else
      "brouillon enregistré le #{I18n.l(local_time(object.updated_at), format: :long_human)}"
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

  def recipients(limit = 50, offset = 0)
    object.recipients.includes(:user_profile).limit(limit).offset(offset).map do |recipient|
      {
        email:  recipient.email,
        name:   recipient.user_profile.user.name,
        clicks: recipient.clicks,
        opens:  recipient.opens
      }
    end
  end
end
