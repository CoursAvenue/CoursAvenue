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
    Bugsnag.notify(RuntimeError.new("EmailProcessor#process"), {
      email_data: {
        json: @email.to_json,
        to: @email.to.first[:token],
        body: @email.body
      }
    })

    token = ReplyToken.find @email.to.first[:token]

    case token.reply_type
    when 'participation_request'
      process_participation_request(token)
    when 'conversation'
      process_conversation(token)
    end
  end

  private

  def process_participation_request(reply_token)
    pr = ParticipationRequest.find reply_token.participation_request_id.to_i

    if reply_token.sender_type.downcase == 'admin'
      sender = Admin.find reply_token.sender_id.to_i
    else
      sender = User.find reply_token.sender_id.to_i
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
  end
end
