class Comment::Review < Comment

  MIN_NB_WORD_CONTENT  = 20

  friendly_id :unique_token, use: [:slugged, :finders]

  attr_accessible :author_name, :email, :rating, :title, :course_name, :deletion_reason, :subjects, :subject_ids,
                  :associated_message_id, :certified, :status

  # A comment has a status which can be one of the following:
  #   - accepted
  #   - waiting_for_deletion
  ######################################################################
  # Relations                                                          #
  ######################################################################
  belongs_to :user
  belongs_to :associated_message, class_name: 'Mailboxer::Message', foreign_key: :associated_message_id

  has_one :reply, class_name: 'Comment::Reply', as: :commentable

  has_and_belongs_to_many :subjects, foreign_key: 'comment_id'

  ######################################################################
  # Validations                                                        #
  ######################################################################
  validates :email, format: { with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i }
  validates :email, :author_name, :course_name, :title, presence: true
  validates :rating, presence: true, on: :create
  validate  :doesnt_exist_yet, on: :create
  validate  :content_length, on: :create

  ######################################################################
  # Callbacks                                                          #
  ######################################################################
  before_create    :set_status
  before_create    :remove_quotes_from_title

  before_save      :strip_names
  before_save      :downcase_email
  before_save      :sanatize_content

  after_create     :create_user, if: -> { self.user.nil? }
  after_create     :send_email
  after_create     :affect_structure_to_user
  after_create     :create_passions_for_associated_user
  after_create     :complete_comment_notification
  after_create     :create_or_update_user_profile

  after_destroy    :remove_highlighted_comment_id_from_commentable

  ######################################################################
  # Scopes                                                             #
  ######################################################################
  scope :ordered                  , -> { order('created_at DESC') }
  scope :accepted                 , -> { where(status: 'accepted') }
  scope :waiting_for_deletion     , -> { where(status: 'waiting_for_deletion') }
  scope :certified                , -> { where(certified: true) }
  scope :not_certified            , -> { where(arel_table[:certified].eq(nil)
                                          .or(arel_table[:certified].eq(false))) }

  # ------------------------------------------------------------------------------------ Search attributes
  # :nocov:
  searchable do
    text :title, boost: 5
    text :course_name, boost: 10
    text :content

    latlon :location, multiple: true do
      self.structure.places.collect do |place|
        Sunspot::Util::Coordinates.new(place.latitude, place.longitude)
      end
    end

    boolean :certified
    boolean :has_title do
      self.title.present?
    end

    boolean :has_avatar do
      if self.user
        self.user.has_avatar?
      else
        false
      end
    end

    string :subject_slugs, multiple: true do
      subject_slugs = []
      self.structure.subjects.uniq.each do |subject|
        subject_slugs << subject.slug
        subject_slugs << subject.root.slug if subject.root
      end
      subject_slugs.uniq
    end

    string :subject_slug do
      if self.subjects.any?
        self.subjects.first.slug
      else
        self.structure.dominant_root_subject.slug
      end
    end

    time :created_at
    boolean :accepted do
      self.accepted?
    end
  end
  # :nocov:

  def recover!
    self.status = :accepted
    self.save
  end

  def accept!
    self.status = :accepted
    self.save
    self.notify_user
  end

  def ask_for_deletion!(deletion_reason=nil)
    self.status          = :waiting_for_deletion
    self.deletion_reason = deletion_reason if deletion_reason
    self.save
    SuperAdminMailer.delay.ask_for_deletion(self)
  end

  def waiting_for_deletion?
    self.status == 'waiting_for_deletion'
  end

  def accepted?
    self.status == 'accepted'
  end

  def structure
    self.commentable
  end

  def owner?(user)
    if user.is_a? Admin
      user.super_admin or self.commentable == user.structure
    else
      self.user == user
    end
  end

  def highlighted?
    self.commentable.highlighted_comment_id == self.id
  end

  protected

  # Set status to accepted by default
  #
  # @return nil
  def set_status
    self.status ||= 'accepted'
    nil
  end

  def notify_user
    UserMailer.delay.comment_has_been_validated(self)
  end

  private

  def content_length
    if content and content.split.size < MIN_NB_WORD_CONTENT
      self.errors.add :content, I18n.t('comments.errors.content_too_small', count: MIN_NB_WORD_CONTENT)
    end
  end

  # Creates an inactive user after a comment is created if the user wasn't connected
  #
  # @return nil
  def create_user
    user_email = email
    if (user = User.where( email: user_email ).first).nil?
      user = User.new email: email
      user.first_name = author_name.split(' ')[0..author_name.split(' ').length - 2].join(' ')
      user.last_name  = author_name.split(' ').last        if self.author_name.split(' ').length > 1
    end

    self.user = user
    user.save(validate: false)
    self.save
    nil
  end

  def affect_structure_to_user
    self.user.structures << self.structure
    self.user.save(validate: false)
  end

  def create_passions_for_associated_user
    self.subjects.each do |child_subject|
      passion = self.user.passions.build(practiced: true)
      passion.subjects << child_subject.root
      passion.subjects << child_subject
    end
    self.user.comments << self
    self.user.save(validate: false)
  end

  def complete_comment_notification
    _structure_id = self.structure.id
    if (comment_notification = user.comment_notifications.where(structure_id: _structure_id).first).present?
      comment_notification.complete!
    end
  end

  # Add errors if the user has already commented the commentable AND it's less
  # than a year old
  #
  # @return nil
  def doesnt_exist_yet
    _structure_id = self.commentable_id
    _email        = self.email
    if Comment::Review.where( Comment::Review.arel_table[:commentable_id].eq(_structure_id).and(
                      Comment::Review.arel_table[:email].eq(_email).and(
                      Comment::Review.arel_table[:created_at].gt(1.year.ago))) ).any?
      self.errors.add :email, I18n.t('comments.errors.already_posted')
    end
  end

  #
  # Strip names in case they have a starting or ending space
  #
  # @return nil
  def strip_names
    self.author_name = self.author_name.strip if author_name.present?
    self.title       = self.title.strip       if title.present?
    self.course_name = self.course_name.strip if course_name.present?
  end

  # Sends an email to the user and the admin regarding the status of the comment
  #
  # @return nil
  def send_email
    if self.accepted?
      UserMailer.delay.congratulate_for_accepted_comment(self)
      AdminMailer.delay.congratulate_for_accepted_comment(self)
    else
      AdminMailer.delay.congratulate_for_comment(self)
      UserMailer.delay.congratulate_for_comment(self)
    end
  end

  # Change the email to force it to be downcase
  #
  # @return
  def downcase_email
    self.email = self.email.downcase
    nil
  end

  # Remove quotes from title if they are at the begining
  #
  # @return nil
  def remove_quotes_from_title
    string_title = self.title
    string_title[0]                       = '' if string_title[0] == '"' or string_title[0] == "'"
    string_title[string_title.length - 1] = '' if string_title.last == '"' or string_title.last == "'"
    self.title = string_title.strip
    nil
  end

  # Create or update the user profile attached to the structure
  #
  # @return nil
  def create_or_update_user_profile
    user_profile = UserProfile.update_info(structure, user)
    # Tag it as commented
    structure.add_tags_on(user_profile, UserProfile::DEFAULT_TAGS[:comments])
    nil
  end

  # Remove unwanted character from the content
  #
  # @return nil
  def sanatize_content
    self.content = StringHelper.sanatize(self.content) if self.content.present?
    nil
  end

  # Prevent from having a deleted comment as highlighted
  #
  # @return nil
  def remove_highlighted_comment_id_from_commentable
    if commentable and commentable.highlighted_comment_id == id
      commentable.highlighted_comment_id = nil
      commentable.save
    end
    nil
  end
end
