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
end
