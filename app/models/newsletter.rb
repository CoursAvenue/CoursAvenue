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
    if sender_name.nil?
      self.sender_name = self.structure.name
    end

    if reply_to.nil? and structure.contact_email.present?
      self.reply_to = self.structure.contact_email
    end

    if object.nil?
      self.object = self.title
    end

    save
  end
end
