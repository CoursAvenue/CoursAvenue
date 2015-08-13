class Community::MessageSerializer < ActiveModel::Serializer
  include ActionView::Helpers::TextHelper
  include ActionView::Helpers::DateHelper

  attributes :id, :thread_id, :content, :distance_of_time, :created_at, :created_at_iso,
             :author_name, :avatar_url, :has_avatar

  def has_avatar
    if object.sender_type == 'User'
      sender = User.find(object.sender_id)
      sender.has_avatar?
    else
      sender = Admin.find(object.sender_id)
      sender.structure.logo.present?
    end
  end

  def avatar_url
    if object.sender_type == 'User'
      sender = User.find(object.sender_id)
      sender.avatar_url(:thumb)
    else
      sender = Admin.find(object.sender_id)
      sender.avatar
    end
  end

  def content
    simple_format(object.body)
  end

  def created_at_iso
    I18n.l(object.created_at, format: :iso_date_8601)
  end

  def author_name
    object.sender.name
  end

  def distance_of_time
    distance_of_time_in_words_to_now(object.created_at)
  end

  def thread_id
    @options[:thread_id]
  end
end
