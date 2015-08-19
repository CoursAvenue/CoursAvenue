class UserSerializer < ActiveModel::Serializer
  include ApplicationHelper

  cached
  delegate :cache_key, to: :object

  attributes :id, :email, :name, :first_name, :last_name, :avatar_url, :slug,
             :favorite_structure_ids, :last_messages_sent, :created_at, :gender, :phone_number

  def favorite_structure_ids
    object.favorites.pluck(:structure_id).compact
  end

  def last_messages_sent
    data = {}
    object.participation_requests.group_by(&:structure_id).each do |structure_id, participation_requests|
      data[structure_id] = I18n.l(local_time(participation_requests.sort_by(&:created_at).last.created_at), format: :date_short)
    end
    data
  end

  def avatar_url
    object.avatar_url(:small)
  end
end
