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

  # The URL of the invoice as a PDF. (Hosted on S3)
  #
  # @return nil or a string.
  def pdf_url
    return nil if stripe_invoice_id.nil?
    generate_pdf! if pdf_file_path.nil?

    pdf_file_path
  end

  private

  # Generate the PDF for the invoice.
  #
  # @return nil or a String
  def generate_pdf!
    self.pdf_file_path = PDFGenerator.generate_invoice(self, pdf_template)
    save
  end

  # The template to use of the PDF generation.
  #
  # @return a String.
  def pdf_template
    'pro/subscriptions/invoices.pdf.haml'
  end
end
