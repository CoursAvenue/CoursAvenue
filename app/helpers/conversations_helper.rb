# encoding: utf-8
module ConversationsHelper

  # Take out extra infos from a conversation
  # @param conversation
  #
  # @return Array of extra_infos, eg: ['inscription', 'be_called']
  def conversation_participation_request(conversation)
    if conversation.mailboxer_label_id == Mailboxer::Label::REQUEST.id
      ParticipationRequest.where(mailboxer_conversation_id: conversation.id).first
    end
  end

  # Take out extra infos from a conversation
  # @param conversation
  #
  # @return Array of extra_infos, eg: ['inscription', 'be_called']
  def conversation_extra_infos(conversation)
    extra_infos = Mailboxer::ExtraInfo.find(conversation.mailboxer_extra_info_ids.split(',')) if conversation.mailboxer_extra_info_ids.present?
  end

  # Take out courses associated to a conversation
  # @param conversation
  # @param structure
  #
  # @return Array of Courses
  def conversation_courses(conversation, structure)
    courses = structure.courses.with_deleted.find(conversation.mailboxer_course_ids.split(',')) if conversation.mailboxer_course_ids.present?
  end

  # Take out the label of the conversation
  # @param conversation
  #
  # @return String as HTML
  def conversation_label(conversation, options={})
    label = Mailboxer::Label.find(conversation.mailboxer_label_id)
    content_tag :span, class: "lbl--small lbl--chip lbl lbl--#{label.color} #{options[:class]}" do
    end
  end

  def conversation_label_name(conversation)
    label = Mailboxer::Label.find(conversation.mailboxer_label_id)
    I18n.t(label.name)
  end

  # Tells wether or not the admin has responded to the message
  #
  # @param Mailboxer::Conversation
  #
  # @return Boolean
  def conversation_waiting_for_reply? conversation, by='Structure'
    if conversation.mailboxer_label_id == Mailboxer::Label::INFORMATION.id
      senders = conversation.messages.map(&:sender).compact.uniq
      if senders.length == 1 and !conversation.treated_by_phone
        return true
      end
    elsif conversation.mailboxer_label_id == Mailboxer::Label::REQUEST.id
      participation_request = conversation_participation_request(conversation)
      return (participation_request.present? and participation_request.pending? and participation_request.last_modified_by != by and !participation_request.past?)
    end

    return false
  end

  # Wether or not the message is a duplicate from a previous message from the same user.
  #
  # @param user The user sending the message.
  # @param message The message to check.
  # @param structure The Structure related to the message.
  # @param interval=2.day the interval within the message is considered as duplicate.
  #
  # @return Boolean
  def duplicate_message?(user, message, structure, interval=2.day)
    recipient = structure.admin
    conversations = user.mailbox.sentbox.where(mailboxer_label_id: Mailboxer::Label::INFORMATION.id)

    messages = []
    conversations.each do |conversation|
      messages += conversation.messages.where(created_at: (Time.now - interval)..Time.now)
    end

    duplicate = messages.find do |original|
      original.body == message[:body] && recipient.in?(original.recipients)
    end

    return duplicate.present?
  end

  def conversation_has_deleted_user?(conversation)
    user_message = conversation.messages.detect { |message| message.sender_type == 'User' }
    return false if user_message.nil?

    user = User.only_deleted.where(id: user_message.sender_id).first

    (user.present? and user.deleted?)
  end
end
