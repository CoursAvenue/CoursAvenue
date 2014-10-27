class UserSerializer < ActiveModel::Serializer
  include ApplicationHelper

  cached
  delegate :cache_key, to: :object

  attributes :id, :email, :name, :first_name, :last_name, :avatar_url, :slug, :favorite_structure_ids, :last_message_sent,
             :has_discovery_pass, :created_at, :gender, :just_signed_up

  def favorite_structure_ids
    object.followings.map(&:structure_id)
  end

  def last_message_sent
    if @options[:structure].present? and @options[:structure].persisted?
      structure_mailbox = @options[:structure].mailbox
      return if structure_mailbox.nil?
      object.mailbox.conversations.where(mailboxer_label_id: Mailboxer::Label::INFORMATION.id).order('created_at DESC').each do |conversation|
        if structure_mailbox.conversations.where(id: conversation.id).any?
          return I18n.l(local_time(conversation.created_at), format: :date_short)
        end
      end
      nil
    end
  end

  def has_discovery_pass
    object.discovery_pass.present?
  end

  def just_signed_up
    return (object.created_at > Date.today.beginning_of_day)
  end
end
