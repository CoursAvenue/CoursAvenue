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

    # TODO Add mixpanel tracker to track how many people reply by email.
    token = ReplyToken.find @email.to.first[:token]

    case token.reply_type
    when 'participation_request'
      process_participation_request(token)
    when 'conversation'
      process_conversation(token)
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
        pr.structure.main_contact.reply_to_conversation(pr.conversation, message)
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

  def track_reply(reply_token)
    if Rails.env.production?
      @mixpanel_tracker = Mixpanel::Tracker.new(ENV['MIXPANEL_PROJECT_TOKEN'])
      @mixpanel_tracker.track("Replied to conversation", { reply_type: reply_token.reply_type, sender_type: reply_token.sender_type, sender_id: reply_token.sender_id } )
    end
  end
end
