class PDFGenerator
  # TODO: Implement (see Order#upload_invoice)
  # Generate the invoice in a PDF format and uploads it to S3.
  #
  # @param invoice The invoice to generate
  # @param template The template to use for the generatio:
  #
  # @return the URL of the generated invoice.
  def self.generate_invoice(invoice, template)
    return nil if invoice.nil? or template.nil?
  end
end
