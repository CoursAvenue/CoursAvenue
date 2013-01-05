class PriceSerializer < ActiveModel::Serializer
  attributes  :id,
              :libelle,
              :amount
end
