class MetroLineSerializer < ActiveModel::Serializer

  cached
  delegate :cache_key, to: :object

  attributes :number, :number_without_bis, :is_bis, :line_type

  def number_without_bis
    object.number_without_bis
  end

  def is_bis
    object.bis?
  end
end
