class Community::MessageSerializer < ActiveModel::Serializer
  include ActionView::Helpers::TextHelper
  include ActionView::Helpers::DateHelper

  cached
  delegate :cache_key, to: :object

  attributes :id, :thread_id, :content, :created_at, :created_at_iso,
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

  def thread_id
    @options[:thread_id]
  end
end
