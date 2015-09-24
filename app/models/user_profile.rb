# encoding: utf-8
class UserProfile < ActiveRecord::Base
  acts_as_taggable_on :tags
  acts_as_paranoid

  PER_PAGE_CRM = 20
  DEFAULT_TAGS = {
    :comments              => 'Avis',
    :contacts              => "Demande d'info",
    :following             => 'Favori',
    :participation_request => "Demande d'inscription"
  }

  belongs_to :structure
  belongs_to :user
  has_many :newsletter_recipients, class_name: 'Newsletter::Recipient'

  attr_accessible :email, :first_name, :last_name, :birthdate, :notes, :phone, :mobile_phone,
                  :address, :structure_id, :subscribed

  after_create :associate_to_user_or_create

  before_validation :affect_email_if_empty
  before_save       :downcase_email

  validates :email, format: { with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i }, allow_blank: true
  validate :presence_of_mandatory_fields

  scope :with_email, -> { where( UserProfile.arel_table[:email].not_eq(nil).or(
                                 UserProfile.arel_table[:email].not_eq('')) )}

  scope :with_name,  -> { where( UserProfile.arel_table[:first_name].not_eq('').or(
                                 UserProfile.arel_table[:last_name].not_eq('')) )}

  def name
    self.full_name
  end

  def full_name
    "#{first_name} #{last_name}"
  end

  def name_with_email
    if self.full_name.present?
      "#{self.full_name} (#{self.email})"
    else
      self.email
    end
  end

  ######################################################################
  # Bulk actions                                                       #
  ######################################################################

  # it should call the method with the given name
  # the method should receive the arguments it expects
  # after the call, the structure attribute busy should be false
  def self.perform_bulk_job(ids, job, *args)
    args = nil if args.compact.empty? # Prevent from [nil]

    user_profiles = self.find(ids)
    structure     = user_profiles.first.structure

    user_profiles.each do |profile|
      profile.send(job, *args)
    end

    structure.busy = false
    structure.save
  end

  def add_tags(tags)
    tags = [tags] unless tags.is_a? Array
    self.structure.add_tags_on(self, tags)
  end

  # Updates or create a user profile to the given structure based on
  # a user information
  # @param  _structure Structure
  # @param  _user User
  #
  # @return UserProfile
  def self.update_info(_structure, _user)
    user_profile              = _structure.user_profiles.where(email: _user.email).first_or_create
    user_profile.user       ||= _user
    user_profile.first_name ||= _user.first_name
    user_profile.last_name  ||= _user.last_name
    user_profile.save
    user_profile
  end

  # Create user profiles based on an array of emails
  # @param structure The strucure to associate the profiles to.
  # @param emails Array or string
  # @param options Some options for the notification sent to the teacher.
  #
  # @return nil
  def self.batch_create(structure, emails, options = {})
    unless emails.is_a? Array
      regexp = Regexp.new(/\b[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}\b/)
      emails = emails.scan(regexp).uniq
    end
    total        = emails.length
    error_emails = []
    emails.each do |email|
      user_profile = structure.user_profiles.where(email: email).first_or_initialize
      created      = user_profile.save
      if created
        structure.tag(user_profile, with: options[:mailing_list_tag], on: :tags) if options[:mailing_list_tag].present?
      end
      error_emails << email unless created
    end

    # if options.present? and options[:newsletter_id].present?
    #   newsletter = structure.newsletters.friendly.find(options[:newsletter_id])
    #   AdminMailer.delay(queue: 'mailers').import_batch_user_profiles_finished_from_newsletter(structure, newsletter, total, error_emails)
    # else
    #   AdminMailer.delay(queue: 'mailers').import_batch_user_profiles_finished(structure, total, error_emails)
    # end
  end

  private

  def affect_email_if_empty
    if self.user && self.email.blank?
      self.email = self.user.email
    end
  end

  def associate_to_user_or_create
    if self.user.nil? and self.email.present?
      if (u = User.where(email: self.email).first).nil?
        u = User.new(email: self.email, first_name: self.first_name, last_name: self.last_name)
        u.save(validate: false)
      end
      self.user = u
      self.save
    end
  end

  def presence_of_mandatory_fields
    if self.email.blank? and self.first_name.blank? and self.last_name.blank?
      self.errors[:base] << I18n.t('user_profile.errors.no_info_on_name_or_email')
    end
  end

  # Change the email to force it to be downcase
  #
  # @return
  def downcase_email
    self.email = self.email.downcase if self.email
    nil
  end
end
