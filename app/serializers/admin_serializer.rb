class AdminSerializer < ActiveModel::Serializer
  attributes :premium

  def premium
    if object.structure
      object.structure.premium?
    end
  end

end
