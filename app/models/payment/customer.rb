class Payment::Customer < ActiveRecord::Base
  belongs_to :client, polymorphic: true

  delegate :name,  to: :client, allow_nil: true
  delegate :email, to: :client, allow_nil: true

  def stripe_customer
    return nil if stripe_customer_id.nil?

    Stripe::Customer.retrieve(stripe_customer_id)
  end

  def create_stripe_customer(token)
    return nil if token.nil?

    metadata = {}
    metadata[client_type] = client_id

    if client_type == 'Structure'
      description = "Compte client pour la structure #{ name } (id = #{ client_id })"
    else
      description = "Compte client pour l'utilisateur #{ name } (id = #{ client_id })"
    end

    stripe_customer = Stripe::Customer.create({
      description: description,
      source: token,
      metadata: metadata
    })

    self.stripe_customer_id = stripe_customer.id
    save

    stripe_customer
  end
end
