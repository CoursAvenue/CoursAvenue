class UserProfileSerializer < ActiveModel::Serializer

  has_many :tags

  attributes :id, :email, :first_name, :last_name, :birthdate, :notes,
             :phone, :mobile_phone, :address, :path, :tag_name

  def path
    pro_structure_user_profile_path(object.structure, object)
  end

  def tag_name
    object.tags.map(&:name).join(', ') if not object.tags.empty?
  end
end
