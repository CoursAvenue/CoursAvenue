class UserSerializer < ActiveModel::Serializer
  include ApplicationHelper

  cached
  delegate :cache_key, to: :object

  attributes :id, :email, :name, :first_name, :last_name, :avatar_url, :slug, :favorite_structure_ids, :last_messages_sent,
             :has_discovery_pass, :created_at, :gender

  def favorite_structure_ids
    object.followings.map(&:structure_id)
  end

  def last_messages_sent
    data = {}
    object.mailbox.conversations.each do |conversation|
      structure = conversation.recipients.detect{|r| r.is_a? Admin}.try(:structure)
      data[structure.id] = I18n.l(local_time(conversation.created_at), format: :date_short) if structure
    end
    data
  end

  def has_discovery_pass
    object.discovery_pass.present?
  end

  def avatar_url
    object.avatar_url(:small)
  end
end
