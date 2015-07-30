class CommunitySerializer < ActiveModel::Serializer
  attributes :id, :message_threads, :message_count

  def message_threads
    object.message_threads.includes(conversation: [:messages]).map do |thread|
      {
        id: thread.id,
        messages: thread.conversation.messages,
        asker: thread.membership.user
      }
    end
  end

  # The count of message already exchanged, including answers.
  def message_count
    object.message_threads.includes(:conversation).
      flat_map(&:conversation).
      flat_map(&:messages).count
  end
end
