class NewsletterMailingListSerializer < ActiveModel::Serializer

  attributes :id, :name, :all_profiles, :recipient_count, :structure_id

  def recipient_count
    object.recipient_count
  end
end
