class PriceSerializer < ActiveModel::Serializer
  attributes  :id,
              :libelle,
              :amount

  validates :libelle, :uniqueness => true
end
