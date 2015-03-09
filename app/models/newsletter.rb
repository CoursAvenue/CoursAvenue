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
    :layout_id,
    :blocs, :blocs_attributes

  belongs_to :structure
  has_many :blocs,         class_name: 'Newsletter::Bloc'
  has_many :mailing_lists, class_name: 'Newsletter::MailingList'


  accepts_nested_attributes_for :blocs
                                # reject_if: :reject_bloc,
                                # allow_destroy: true

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

  # TODO: Remove this when the mailing_list model is created.
  def mailing_list
    "Inscrits a la newsletter"
  end

  # TODO: Move these two methods in a concern ?
  def sent?
    state == 'sent'
  end

  def draft?
    state == 'draft'
  end

  # TODO: Move this into a View helper.
  def string_status
    if sent?
      "envoyée le #{I18n.l(sent_at, format: :long_human)}"
    else
      "brouillon enregistré le #{I18n.l(updated_at, format: :long_human)}"
    end
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

    if layout_id.nil?
      self.layout_id = 1
    end

    save
  end

  # Check if we should reject the bloc.
  # We only reject it if the bloc has no content or no image.
  #
  # @return a Boolean.
  def reject_bloc(attributes)
    exists = attributes[:id].present?
    blank = (attributes[:content].blank? or
             attributes[:remote_image_url].blank? or
             attributes[:image].blank?)

    if blank and exists
      attributes.merge!({ :_destroy => 1 })
    end

    (blank and !exists)
  end
end
