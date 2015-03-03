class Newsletter < ActiveRecord::Base

  ######################################################################
  # Constants                                                          #
  ######################################################################

  NEWSLETTER_STATES = %w(draft sent)

  ######################################################################
  # Macros                                                             #
  ######################################################################

  attr_accessible :title, :content, :state, :object, :sender_name, :reply_to

  belongs_to :structure

  validates :title, presence: true
  validates :content, presence: true
  validates :state, presence: true

  after_create :set_defaults

  ######################################################################
  # Methods                                                            #
  ######################################################################

  private

  # Sets the default values for the sender name, the reply_to address and the
  # object.
  #
  # @return self.
  def set_defaults
    name     = structure.name if name.nil?
    reply_to = structure.contact_email if reply_to.nil? and structure.contact_email.present?
    object   = title if object.nil?

    save
  end
end
