class Community::MessageThreadsSerializer < ActiveModel::Serializer
  include ActionView::Helpers::TextHelper
  include ActionView::Helpers::DateHelper

  attributes :id, :community_id, :messages

  def messages
    return [] if object.conversation.nil?

    object.conversation.messages.map do |message|
      if message.sender_type == 'User'
        sender = User.find(message.sender_id)
        avatar_url = sender.avatar.url
      else
        sender = Admin.find(message.sender_id)
        avatar_url = sender.avatar
      end

      {
        id: message.id,
        content: message.body,
        avatar_url: avatar_url,
        created_at: message.created_at,
        author_name: sender.name,
        distance_of_time: distance_of_time_in_words_to_now(message.created_at),
        created_at_iso: I18n.l(message.created_at, format: :iso_date_8601)
      }
    end
  end
end
