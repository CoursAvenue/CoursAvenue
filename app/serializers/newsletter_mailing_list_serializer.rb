class NewsletterMailingListSerializer < ActiveModel::Serializer
  attributes :id, :name, :all_profiles. :filters

  # TODO: Check if it is relevant to have the number of user profiles.
  def user_count
  end
end
