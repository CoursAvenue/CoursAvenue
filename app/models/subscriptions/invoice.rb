class Subscriptions::Invoice < ActiveRecord::Base
  acts_as_paranoid

  ######################################################################
  # Macros                                                             #
  ######################################################################

  attr_accessible :stripe_invoice_id, :structure, :subscription

  belongs_to :structure
  belongs_to :subscription

  ######################################################################
  # Methods                                                            #
  ######################################################################

  # Create a Subscriptions::Invoice from a Stripe::Invoice
  #
  # @param stripe_invoice The Stripe invoice.
  #
  # @return The Subscription::Invoice
  def self.create_from_stripe_invoice(stripe_invoice)
    return nil if stripe_invoice.nil?

    invoice = where(stripe_invoice_id: stripe_invoice.id).first
    return invoice unless invoice.nil?

    subscription = Subscription.where(stripe_subscription_id: stripe_invoice.subscription).first
    structure    = subscription.structure

    create!(structure: structure, subscription: subscription, stripe_invoice_id: stripe_invoice.id)
  end

  # TODO: Memoize object.
  # Retrieve the Stripe::Invoice.
  #
  # @return nil or a Stripe::Invoice.
  def stripe_invoice
    return nil if stripe_invoice_id.nil?

    Stripe::Invoice.retrieve(stripe_invoice_id)
  end

  # The URL of the invoice as a PDF. (Hosted on S3)
  #
  # @return nil or a string.
  def pdf_url
    return nil if stripe_invoice_id.nil?
    generate_pdf! unless self.generated?

    file = CoursAvenue::Application::S3_BUCKET.objects[file_path]
    file.url_for(:read, expires: 10.years.from_now).to_s
  end

  # The path of the invoice file on S3.
  #
  # @return a String.
  def file_path
    "invoices/#{self.structure.slug}/#{self.id}.pdf"
  end

  private

  # Generate the PDF for the invoice.
  #
  # @return nil or a String
  def generate_pdf!
    PDFGenerator.generate_invoice(self, pdf_template)
    self.generated = true
    save
  end

  # The template to use of the PDF generation.
  #
  # @return a String.
  def pdf_template
    'pro/subscriptions/invoices.pdf.haml'
  end
end
