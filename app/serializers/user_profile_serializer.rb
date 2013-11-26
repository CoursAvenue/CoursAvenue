class UserProfileSerializer < ActiveModel::Serializer

  attributes :email, :first_name, :last_name, :birthdate, :notes, :phone, :mobile_phone, :address

end
