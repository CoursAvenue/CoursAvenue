class ::Admin < ActiveRecord::Base
  CIVILITY = [
    'civility.male',
    'civility.female'
  ]
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :invitable, :database_authenticatable,
         :recoverable, :rememberable, :trackable, :validatable, :registerable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me, :civility, :first_name, :last_name, :phone_number, :mobile_phone_number, :activated, :management_software_used, :role

  validates :first_name, :last_name, presence: true
  # attr_accessible :title, :body
  belongs_to :structure

  def fullname
    "#{first_name} #{last_name}"
  end
end
