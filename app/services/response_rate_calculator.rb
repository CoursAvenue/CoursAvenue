class ResponseRateCalculator
  LIMIT = 6.months

  def self.update_for(structure)
    if structure.admin.present?
      self.new(structure).update
    end
  end

  def initialize(structure)
    @structure = structure
    @admin = structure.admin
  end

  def update
    return if @admin.nil?

    @structure.response_rate = response_rate.round
    @structure.response_time = response_time
    @structure.save(validate: false)
  end

  private

  def response_rate
    conversations_total_count = participation_requests.count + conversations.count
    replied_conversation_count = replied_participations.count + replied_conversations.count

    if conversations_total_count == 0
      response_rate = nil
    else
      response_rate = (replied_conversation_count.to_f / conversations_total_count.to_f) * 100
    end
  end

  def response_time
    delta_hours = []
    replied_conversations.each do |conversation|
      if conversation.read_attribute(:treated_by_phone)
        first_message = conversation.messages.minimum(:created_at)
        delta = ( (conversation.read_attribute(:treated_at) - first_message).abs.round / 60 ) / 60
      else
        admin_message = conversation.messages.where(sender_type: 'Admin').minimum(:created_at)
        user_message = conversation.messages.where(sender_type: 'User').minimum(:created_at)

        next if (admin_message.nil? or user_message.nil?)

        delta = ((admin_message - user_message).abs.round / 60) / 60
      end
      delta_hours << delta
    end
  end

  def participation_requests
    @participation_requests ||= @structure.participation_requests.where(created_at: period)
  end

  def replied_participations
    participation_requests.where.not(state: 'pending')
  end

  def conversations
    @conversations ||= @admin.mailbox.conversations.includes(messages: :sender).where(
      mailboxer_label_id: [
        Mailboxer::Label::INFORMATION.id, Mailboxer::Label::PUBLIC_QUESTION.id
    ], created_at: period)
  end

  def replied_conversations
    conversations.select do |conversation|
      # We consider a conversation replied when the repliers include the admin (actual reply) or
      # when the admin treated the conversation by phone (implicit reply).
      conversation.read_attribute(:treated_by_phone) or conversation.messages.map(&:sender).include?(@admin)
    end
  end

  def period
    LIMIT.ago..Time.current
  end
end
