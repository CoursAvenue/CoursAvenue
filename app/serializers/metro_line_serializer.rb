class MetroLineSerializer < ActiveModel::Serializer

  attributes :number, :number_without_bis, :is_bis

  def number_without_bis
    object.number_without_bis
  end

  def is_bis
    object.bis?
  end
end
