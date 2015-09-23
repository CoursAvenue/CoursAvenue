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
  end

  def participation_requests
    @participation_requests ||= @structure.participation_requests.where(created_at: period)
  end

  def replied_participations
    participation_requests.where.not(state: 'pending')
  end

  def conversations
    @conversations ||= @admin.mailbox.conversations.includes(:messages).where(mailboxer_label_id: [
      Mailboxer::Label::INFORMATION.id, Mailboxer::Label::PUBLIC_QUESTION.id
    ], created_at: period)
  end

  def replied_conversations
    conversations.select do |conversation|
      # We consider a conversation replied when the recipients include the admin (actual reply) or
      # when the admin treated the conversation by phone (implicit reply).
      conversation.recipients.include?(@admin) or conversation.read_attribute(:treated_by_phone)
    end
  end

  def period
    LIMIT.ago..Time.current
  end
end
