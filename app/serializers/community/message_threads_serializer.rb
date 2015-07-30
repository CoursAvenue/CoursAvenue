class Community::MessageThreadsSerializer < ActiveModel::Serializer
  attributes :id, :community_id, :messages

  def messages
    return [] if object.conversation.nil?

    object.conversation.messages.map do |message|
      sender = message.sender_type == 'User' ? User.find(message.sender_id) : Admin.find(message.sender_id)
      {
        id: message.id,
        body: message.body,
        sender: {
          id: message.sender_id,
          name: sender.name,
        },
        date: I18n.l(message.created_at, format: :long_human)
      }
    end
  end
end
