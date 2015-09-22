class Mailboxer::PrivateMessageForm
  include ActiveModel::Model
  include Virtus.model

  attr_reader :structure
  attr_reader :user
  attr_reader :conversation

  attribute :message, String
  validates :message, presence: true

  attribute :structure_id, Integer
  validates :structure_id, presence: true

  # Make sure to set the user_id in the controller if not already in the params.
  attribute :user_id, Integer
  validates :user_id, presence: true

  def save
    valid? ? persist! : false
  end

  private

  def persist!
    return false if (message.nil? or message.blank?)

    @user = User.where(id: user_id).first || User.where(slug: user_id).first
    @structure = Structure.where(id: structure_id).first || Structure.where(slug: structure_id).first

    return false if (@user.nil? or @structure.nil?)

    admin = @structure.admin
    return false if admin.nil?

    receipt = @user.send_message_with_label(admin, message,
      I18n.t(Mailboxer::Label::INFORMATION.name), Mailboxer::Label::INFORMATION.id)
    @conversation = receipt.conversation

    true
  end
end
