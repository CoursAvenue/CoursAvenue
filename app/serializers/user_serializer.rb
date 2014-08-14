class UserSerializer < ActiveModel::Serializer
  attributes :id, :name, :first_name, :last_name, :avatar_url, :slug, :favorite_structure_ids, :last_message_sent

  def favorite_structure_ids
    object.followings.map(&:structure_id)
  end

  def last_message_sent
    if @options[:structure].present?
      structure_mailbox = @options[:structure].mailbox
      object.mailbox.conversations.where(mailboxer_label_id: Mailboxer::Label::INFORMATION.id).order('created_at DESC').each do |conversation|
        if structure_mailbox.conversations.where(id: conversation.id).any?
          return I18n.l(conversation.created_at, format: :date_short)
        end
      end
      nil
    end
  end

end
