class NewsletterMailingListSerializer < ActiveModel::Serializer
  attributes :id, :name, :all_profiles, :filters, :tag, :recipient_count

  def recipient_count
    object.recipient_count
  end
end
