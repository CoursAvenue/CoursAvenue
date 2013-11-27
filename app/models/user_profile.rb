class UserProfile < ActiveRecord::Base
  belongs_to :structure
  belongs_to :user

  attr_accessible :email, :first_name, :last_name, :birthdate, :notes, :phone, :mobile_phone, :address

  validates :structure_id, presence: true
  validate :presence_of_email_or_name

  after_create :associate_to_user
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

    integer :structure_id
  end

  def full_name
    "#{first_name} #{last_name}"
  end

  private

  def presence_of_email_or_name
    if self.email.blank? and self.first_name.blank? and self.last_name.blank?
      self.errors[:base] << I18n.t('user_profile.errors.no_info_on_name_or_email')
    end
  end

  def associate_to_user
    if self.email.present?
      u = User.where(email: self.email).first
      if u.nil?
        u = User.new(email: self.email, name: self.full_name)
        u.save(validate: false)
      end
      self.user = u
    end
  end
end
