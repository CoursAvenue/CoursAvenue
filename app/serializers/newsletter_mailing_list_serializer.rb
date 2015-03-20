class NewsletterMailingListSerializer < ActiveModel::Serializer
  attributes :id, :name, :all_profiles, :filters
end
