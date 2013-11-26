class UserProfile < ActiveRecord::Base
  belongs_to :structure
  belongs_to :user

  attr_accessible :email, :first_name, :last_name, :birthdate, :notes, :phone, :mobile_phone, :address
end
