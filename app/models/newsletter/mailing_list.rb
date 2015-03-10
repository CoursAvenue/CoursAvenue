class Newsletter::MailingList < ActiveRecord::Base
  belongs_to :newsletter
  belongs_to :structure

  has_many :subscriptions, class_name: 'Newsletter::Subscription'

  validates :name, presence: true
  validates :tag, presence: true

  after_create :create_subscriptions

  private

  # Create the subscriptions depending on the Mailing List tag.
  # Depending on the number of profiles concerned, this might take a while so we do it async.
  #
  # @return The subscribed profiles.
  def create_subscriptions
    profiles = UserProfile.where(structure: newsletter.structure)

    if self.tag != '_all'
      profiles = profiles.tagged_with(self.tag)
    end

    profiles.each do |profile|
      subscriptions.create(user_profile: profile, subscribed: true)
    end
  end
  handle_asynchronously :create_subscriptions

end
