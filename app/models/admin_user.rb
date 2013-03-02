class AdminUser < ActiveRecord::Base
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
  attr_accessible :email, :password, :password_confirmation, :remember_me, :civility, :firstname, :lastname, :phone_number, :mobile_phone_number
  # attr_accessible :title, :body
  belongs_to :structure
end
