class Subscriptions::InvoiceDecorator < Draper::Decorator
  delegate_all

  def structure_email
    object.structure.contact_email
  end

  def structure_name
    object.structure.name
  end
end
