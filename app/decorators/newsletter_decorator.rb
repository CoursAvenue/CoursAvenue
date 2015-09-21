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
      "pas encore choisie"
    end
  end

  def url
    if object.sent? or object.sending?
      h.metrics_pro_structure_newsletter_path(object.structure, object)
    else
      h.edit_pro_structure_newsletter_path(object.structure, object)
    end
  end

  def badge
    h.content_tag :span, class: ['push-half--left caps white smaller-print very-soft', (object.sent? ? 'bg-green' : 'bg-gray')] do
      if object.state == 'sent'
        'Envoyée'
      elsif object.state == 'sending'
        "En cours d'envoi"
      else
        'Brouillon'
      end
    end
  end

  def recipient_count
    if object.mailing_list.present?
      object.mailing_list.recipient_count
    else
      object.recipients.count
    end
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
