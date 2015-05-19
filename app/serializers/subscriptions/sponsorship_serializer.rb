class Subscriptions::SponsorshipSerializer < ActiveModel::Serializer

  attributes :amount, :name

  def amount
    object.amount_for_sponsored
  end

  def name
    object.name_for_sponsored
  end
end
