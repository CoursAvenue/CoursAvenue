class EmailProcessor
  def initialize(email)
    @email = email
  end

  # Process the reply received to a notification email.
  #
  # In this method, we only parse the reply type and then delegate the actions
  # to other methods: ex: participation_request -> process_participation_request
  # @return nothing
  def process
    return 'OK' if @email.to.first[:token] == 'example'
    return process_image if @email.to.first[:token] == 'flyers'

    token = ReplyToken.find(@email.to.first[:token])

    case token.reply_type
    when 'participation_request'
      process_participation_request(token)
    when 'conversation'
      process_conversation(token)
    when 'comment'
      process_comment(token)
    when 'community'
      process_community_reply(token)
    end

    track_reply(token)

    token.use!
  end

  private

  # Process images received via the special email address `images@reply.coursavenue.com`.
  def process_image
    return if @email.attachments.empty?

    @email.attachments.each do |image|
      flyer = Flyer.create(treated: false, image: image)
    end
  end

  def process_participation_request(reply_token)
    pr = ParticipationRequest.find reply_token.participation_request_id.to_i

    if reply_token.sender_type.downcase == 'admin'
      sender = Admin.find reply_token.sender_id.to_i
    else
      sender = User.find  reply_token.sender_id.to_i
    end

    message = @email.body

    # Here we have several possible cases:
    # * The admin replies to and accepts a request. (case 01)
    # * The user replies to and accepts a request with new details (hours, place, etc)
    if reply_token.sender_type == 'admin'
      if pr.last_modified_by == 'User' and pr.pending? # (case 01)
        pr.accept!(message, 'Structure')
      else
        pr.structure.admin.reply_to_conversation(pr.conversation, message)
        pr.treat!('message')
      end
    elsif reply_token.sender_type == 'user'
      if pr.last_modified_by == 'Admin' and pr.pending? # case 02
        pr.accept!(message, 'User')
      else
        pr.user.reply_to_conversation(pr.conversation, message)
      end
    end
  end

  def process_conversation(reply_token)
    conversation = Mailboxer::Conversation.find reply_token.conversation_id.to_i

    if reply_token.sender_type == 'admin'
      sender = Admin.find reply_token.sender_id.to_i
    else
      sender = User.find  reply_token.sender_id.to_i
    end

    reply = @email.body
    sender.reply_to_conversation(conversation, reply)
  end

  def process_comment(token)
    comment   = Comment::Review.find(token.conversation_id.to_i)
    structure = comment.structure
    message   = @email.body
    return if message.blank?

    if comment.associated_message
      conversation = comment.associated_message.conversation
      structure.admin.reply_to_conversation(conversation, message)
    else
      structure.admin.send_message_with_label(comment.user, message, 'Réponse à votre avis',
                                                     Mailboxer::Label::COMMENT.id)
    end
  end

  def process_community_reply(token)
    return if @email.body.blank?
    thread    = Community::MessageThread.find(token.thread_id.to_i)

    if token.sender_type == 'admin'
      sender = Admin.find(token.sender_id)
    else
      sender = User.find(token.sender_id)
    end

    thread.reply!(sender, @email.body)
  end

  def track_reply(reply_token)
    if Rails.env.production?
      @mixpanel_tracker = MixpanelClientFactory.client
      @mixpanel_tracker.track("Replied to conversation", { reply_type:  reply_token.reply_type,
                                                           sender_type: reply_token.sender_type,
                                                           sender_id:   reply_token.sender_id })
    end
  end
end
