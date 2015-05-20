class ParticipationRequest::Invoice < ActiveRecord::Base
  acts_as_paranoid

  ######################################################################
  # Macros                                                             #
  ######################################################################

  attr_accessible :participation_request, :payed_at

  belongs_to :participation_request

  ######################################################################
  # Methods                                                            #
  ######################################################################

  # The URL of the invoice as a PDF. (Hosted on S3)
  #
  # @return nil or a string.
  def pdf_url
    # return nil if stripe_invoice_id.nil?
    generate_pdf! unless self.generated?

    file = CoursAvenue::Application::S3_BUCKET.objects[file_path]
    file.url_for(:read, expires: 10.years.from_now).to_s
  end

  # The path of the invoice file on S3.
  #
  # @return a String.
  def file_path
    structure = participation_request.structure
    "invoices/#{ structure.slug }/participation_requests/#{ self.id }.pdf"
  end

  # The amount of the invoice.
  #
  # @return Float
  def amount
    participation_request.price
  end

  private

  # Generate the PDF for the invoice.
  #
  # @return nil or a String
  def generate_pdf!
    PDFGenerator.generate_invoice(self, pdf_template, pdf_template_locals)
    self.generated = true

    save
  end

  # The template to use of the PDF generation.
  #
  # @return a String.
  def pdf_template
    'participation_request/invoices.pdf.haml'
  end

  # The locals used in the pdf template.
  #
  # @return a hash.
  def pdf_template_locals
    {
      :@invoice               => self,
      :@participation_request => participation_request,
      :@structure             => participation_request.structure
    }
  end
end
