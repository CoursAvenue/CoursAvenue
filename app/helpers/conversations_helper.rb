# encoding: utf-8
module ConversationsHelper

  def conversation_label(conversation)
    label = Mailboxer::Label.find(conversation.mailboxer_label_id)
    content_tag :span, class: "lbl--chip lbl lbl--#{label.color}" do
    end
  end

  def conversation_label_name(conversation)
    label = Mailboxer::Label.find(conversation.mailboxer_label_id)
    I18n.t(label.name).pluralize(2)
  end
end
