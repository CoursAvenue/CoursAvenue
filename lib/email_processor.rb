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
    if reply_token.sender_type == 'admin'
      pr.accept!(message, 'Structure')
    end
  end

  def process_conversation(reply_token)
  end
end
