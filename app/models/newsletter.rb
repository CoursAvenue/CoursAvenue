class Newsletter < ActiveRecord::Base
  extend ActiveHash::Associations::ActiveRecordExtensions

  ######################################################################
  # Constants                                                          #
  ######################################################################

  NEWSLETTER_STATES = %w(draft sent)

  ######################################################################
  # Macros                                                             #
  ######################################################################

  attr_accessible :title, :state,
    :object, :sender_name, :reply_to,
    :blocs, :layout_id

  belongs_to :structure

  has_many :blocs, class_name: 'Newsletter::Bloc'

  # has_one :layout, class_name: 'Newsletter::Layout'

  validates :title, presence: true
  validates :state, presence: true

  after_create :set_defaults

  ######################################################################
  # Methods                                                            #
  ######################################################################

  # The layout used by the Newsletter.
  #
  # Since Newsletter::Layout is not a regular ActiveRecord inhereited class, we
  # can't use the classic
  #     has_one :layout, class_name: 'Newsletter::Layout'
  # So we just save the layout_id in the model and manually find the
  # corresponding layout.
  #
  # @return Newsletter::Layout or nil.
  def layout
    Newsletter::Layout.where(id: self.layout_id).first
  end

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
