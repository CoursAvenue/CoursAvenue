class Newsletter::MailingList < ActiveRecord::Base
  belongs_to :newsletter
  belongs_to :structure

  has_many :subscriptions, class_name: 'Newsletter::Subscription'

  validates :name, presence: true
  validates :tag, presence: true

  after_create :create_subscriptions

  private

  # Create the subscriptions depending on the Mailing List tag.
  def create_subscriptions
    profiles = UserProfile.where(structure: newsletter.structure).tagged_with(tag)

    profiles.each do |profile|
      subscriptions.create(user_profile: profile, subscribed: true)
    end
  end
  handle_asynchronously :create_subscriptions

end
