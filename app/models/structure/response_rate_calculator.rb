class Structure::ResponseRateCalculator
  LIMIT = 6.months

  def initialize(structure)
    @structure = structure
    @admin = structure.admin
  end

  def update
    return if @admin.nil?

    @structure.response_rate = response_rate
    @structure.response_time = response_time
    @structure.save(validate: false)
  end

  private

  def response_rate
    conversations_total_count = participation_requests.count + conversations.count
    replied_conversation_count = replied_participations.count + replied_conversations.count

    if conversations_total_count == 0
      rate = nil
    else
      rate = ((replied_conversation_count.to_f / conversations_total_count.to_f) * 100).round
    end

    rate
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


    replied_participations.each do |pr|
      if pr.treated_at.present?
        delta = ((pr.treated_at - pr.created_at).abs.round / 60) / 60
      else
        delta = ((pr.updated_at - pr.created_at).abs.round / 60) / 60
      end
      delta_hours << delta
    end

    if delta_hours.empty?
      avg_duration = nil
    else
      avg_duration = (delta_hours.reduce(&:+).to_f / (delta_hours.length.to_f)).round
    end

    avg_duration
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
