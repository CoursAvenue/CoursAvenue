class AdminSerializer < ActiveModel::Serializer
  attributes :id, :structure_id, :premium

  def premium
    if object.structure
      object.structure.premium?
    end
  end

end
