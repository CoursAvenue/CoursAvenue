class UserProfileSerializer < ActiveModel::Serializer

  cached
  delegate :cache_key, to: :object

  has_many :tags

  attributes :id, :email, :first_name, :last_name, :birthdate, :notes,
             :phone, :mobile_phone, :address, :path, :tag_name, :structure_id

  def email
    if object.structure.premium?
      object.email
    else
      object.email.gsub(/.*@/, 'XXXXXXXX@')
    end
  end

  def path
    pro_structure_user_profile_path(object.structure, object)
  end

  def tag_name
    object.tags.map(&:name).join(', ') if not object.tags.empty?
  end
end
