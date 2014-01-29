# encoding: utf-8
class UserProfile < ActiveRecord::Base
  acts_as_taggable_on :tags

  DEFAULT_TAGS = {
    :comments => 'À déposé un avis',
    :contacts => 'À demandé des infos'
  }

  belongs_to :structure
  belongs_to :user

  attr_accessible :email, :first_name, :last_name, :birthdate, :notes, :phone, :mobile_phone,
                  :address, :structure_id

  after_create :associate_to_user

  before_validation :affect_email_if_empty
  validates :email, format: { with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i }, allow_blank: true
  validate :presence_of_mandatory_fields

  # ------------------------------------
  # ------------------ Search attributes
  # ------------------------------------
  searchable do
    text :email
    text :first_name, boost: 5
    text :last_name , boost: 5
    text :notes
    text :phone
    text :mobile_phone

    # for sorting in user_profiles table
    string :email
    string :first_name
    string :last_name

    integer :structure_id
  end

  def full_name
    "#{first_name} #{last_name}"
  end

  def self.import(file)
  end

  private

  def affect_email_if_empty
    if self.user && self.email.blank?
      self.email = self.user.email
    end
  end

  def associate_to_user
    if self.user.nil? and self.email.present?
      if (u = User.where(email: self.email).first).nil?
        u = User.new(email: self.email, first_name: self.first_name, last_name: self.last_name)
        u.save(validate: false)
      end
      self.user = u
    end
  end

  def presence_of_mandatory_fields
    if self.email.blank? and self.first_name.blank? and self.last_name.blank?
      self.errors[:base] << I18n.t('user_profile.errors.no_info_on_name_or_email')
    end
  end

end
