class Community < ActiveRecord::Base
  acts_as_paranoid

  belongs_to :structure

  has_many :message_threads, -> { order(created_at: :desc) },
    class_name: 'Community::MessageThread', dependent: :destroy

  has_many :memberships, class_name: 'Community::Membership', dependent: :destroy
  has_many :users, through: :memberships

  after_create :generate_memberships

  # Ask a question to the community.
  #
  # @return the Thread created by the question.
  def ask_question!(user, message, indexable_card_id = nil)
    membership = memberships.where(user: user).first || memberships.create(user: user)
    thread = membership.message_threads.create(community: self)
    thread.update_column(:indexable_card_id, indexable_card_id.to_i) if indexable_card_id
    thread.send_message!(message)

    thread
  end

  private

  # Generate the memberships with the users already associated with the structure:
  # - The users in the address book,
  # - The users who had an accepted participation request
  # - The users who left comments on the structure's page.
  #
  # @return
  def generate_memberships
    # Don't bother creating memberships if the structure is not defined.
    # This should never happen since we create the communities from the structure using
    # `structure.create_community`, but Fuck You Rails.
    return if structure.nil?

    users = []
    if structure.user_profiles.any?
      users += structure.user_profiles.includes(:user).map(&:user)
    end

    if structure.participation_requests.any?
      users += structure.participation_requests.accepted.includes(:user).map(&:user)
    end

    if structure.comments.any?
      users += structure.comments.includes(:user).map(&:user)
    end

    users = users.uniq.compact

    users.map do |user|
      memberships.where(user: user).first || memberships.create(user: user)
    end
  end
  handle_asynchronously :generate_memberships
end
