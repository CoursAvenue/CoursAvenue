# encoding: utf-8
class UserProfile < ActiveRecord::Base
  acts_as_taggable_on :tags

  DEFAULT_TAGS = {
    :comments => 'Avis',
    :contacts => "Demande d'info",
    :jpo_2014 => "JPO 2014"
  }

  belongs_to :structure
  belongs_to :user

  attr_accessible :email, :first_name, :last_name, :birthdate, :notes, :phone, :mobile_phone,
                  :address, :structure_id

  after_create :associate_to_user_or_create

  before_validation :affect_email_if_empty
  validates :email, format: { with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i }, allow_blank: true
  validate :presence_of_mandatory_fields

  scope :with_email, -> { where{(email != nil) | (email != '')} }

  ######################################################################
  # Search attributes                                                  #
  ######################################################################
  searchable do
    text :email
    text :first_name, boost: 5
    text :last_name , boost: 5
    text :notes
    text :phone
    text :mobile_phone
    text :tag_names do
      self.tags.map(&:name).join(' ')
    end

    # for sorting in user_profiles table
    string :email
    string :first_name
    string :last_name

    string :tag_names, multiple: true do
      self.tags.map(&:name)
    end

    integer :structure_id
    integer :id
  end

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

end
