class PDFGenerator
  LAYOUT = 'layouts/pdf.html.haml'

  # Generate the invoice in a PDF format and uploads it to S3.
  #
  # @param invoice The invoice to generate
  # @param template The template to use for the generatio:
  #
  # @return the URL of the generated invoice.
  def self.generate_invoice(invoice, template, locals = {})
    return nil if invoice.nil? or template.nil?

    file        = CoursAvenue::Application::S3_BUCKET.objects[invoice.file_path]
    invoice_str = ApplicationController.new.render_to_string(template,
                                                             layout: PDFGenerator::LAYOUT,
                                                             locals: locals)


    pdf = WickedPdf.new.pdf_from_string(invoice_str)
    file.write(pdf)

    true
  end

  # Generate a voucher in a PDF format and save it in a Tempfile.
  #
  # @param voucher The voucher to generate
  #
  # @return The TempFile of the generated voucher.
  def self.generate_gift_certificate_voucher(voucher)
    return nil if voucher.nil?

    voucher_str = ApplicationController.new.render_to_string('gift_certificate_voucher/pdf',
                                                             layout: PDFGenerator::LAYOUT,
                                                             locals: { :@voucher => voucher })

    content = WickedPdf.new.pdf_from_string(voucher_str)

    # TODO: Change the id by the token.
    file = Tempfile.new(["voucher-#{ voucher.token }", ".pdf"])
    file.write(content.force_encoding("UTF-8"))
    file.close

    file
  end
end
