# TODO: slugs.
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
    :email_object, :sender_name, :reply_to,
    :layout_id,
    :blocs, :blocs_attributes,
    :newsletter_mailing_list_id

  belongs_to :structure

  has_one :metric,          class_name: 'Newsletter::Metric'
  has_many :blocs,          class_name: 'Newsletter::Bloc',        dependent: :destroy
  has_many :recipients,     class_name: 'Newsletter::Recipient',   dependent: :destroy
  belongs_to :mailing_list, class_name: 'Newsletter::MailingList', foreign_key: :newsletter_mailing_list_id

  accepts_nested_attributes_for :blocs
                                # reject_if: :reject_bloc,
                                # allow_destroy: true

  validates :title, presence: true
  validates :state, presence: true

  after_create :set_defaults
  before_validation :set_title, on: :create

  scope :sent,       -> { where(state: 'sent') }
  scope :drafts,     -> { where(state: 'draft') }

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

  # TODO: Move these two methods in a concern ?
  def sent?
    state == 'sent'
  end

  def draft?
    state == 'draft'
  end

  # Duplicate this Newsletter model.
  #
  # @return the duplicated newsletter.
  def duplicate!
    duplicated_newsletter = structure.newsletters.create({
      title:       self.title,
      state:       'draft',
      email_object:      self.email_object,
      sender_name: self.sender_name,
      reply_to:    self.reply_to,
      layout_id:   self.layout_id
    })

    self.blocs.each do |bloc|
      bloc.duplicate!(duplicated_newsletter)
    end

    duplicated_newsletter
  end

  # Set the newsletter as sent.
  #
  # @return self
  def send!
    self.state = 'sent'
    self.sent_at = Time.now

    save
  end

  private

  # Sets the default values for the sender name, the reply_to address and the
  # email_object.
  #
  # @return self.
  def set_defaults
    if sender_name.nil?
      self.sender_name = self.structure.name
    end

    if reply_to.nil? and structure.contact_email.present?
      self.reply_to = self.structure.contact_email
    end

    if email_object.nil?
      self.email_object = self.title
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

  def set_title
    if self.title.nil?
      self.title = "[Brouillon] Newsletter du #{I18n.l(Time.current, format: :long_human)}"
    end
  end
end