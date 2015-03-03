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
end
