class Subscriptions::Invoice < ActiveRecord::Base
  acts_as_paranoid

  ######################################################################
  # Macros                                                             #
  ######################################################################

  belongs_to :structure
  belongs_to :subscription

  ######################################################################
  # Methods                                                            #
  ######################################################################

  # TODO: Memoize object.
  # Retrieve the Stripe::Invoice.
  #
  # @return nil or a Stripe::Invoice.
  def stripe_invoice
    return nil if stripe_invoice_id.nil?

    Stripe::Invoice.retrieve(stripe_invoice_id)
  end

end
