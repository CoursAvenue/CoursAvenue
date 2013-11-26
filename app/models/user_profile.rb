class UserProfile < ActiveRecord::Base
  belongs_to :structure
  belongs_to :user

  attr_accessible :email, :first_name, :last_name, :birthdate, :notes, :phone, :mobile_phone, :address

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

  def associate_to_user
    unless (u = User.where(email: self.email).first)
      u = User.new(email: self.email, name: self.full_name)
      u.save(validate: false)
    end
    self.user = u
  end
end
