class UserProfileSerializer < ActiveModel::Serializer

  has_many :tags

  attributes :email, :first_name, :last_name, :birthdate, :notes, :phone, :mobile_phone, :address
end
