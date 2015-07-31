class Community < ActiveRecord::Base
  acts_as_paranoid

  belongs_to :structure

  has_many :message_threads, -> { order(created_at: :desc) },
    class_name: 'Community::MessageThread', dependent: :destroy

  has_many :memberships, class_name: 'Community::Membership', dependent: :destroy
  has_many :users, through: :memberships

  # Ask a question to the community.
  #
  # @return the Thread created by the question.
  def ask_question!(user, message)
    membership = memberships.where(user: user).first || memberships.create(user: user)
    thread = membership.message_threads.create(community: self)
    thread.send_message!(message)
    Community::Notifier.new(thread, message, membership).notify_question

    thread
  end
end
