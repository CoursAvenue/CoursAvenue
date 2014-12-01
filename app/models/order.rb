class Order < ActiveRecord::Base
  acts_as_paranoid

  attr_accessible :type, :order_id, :amount, :structure, :subscription_plan, :promotion_code_id

  ######################################################################
  # Callbacks                                                          #
  ######################################################################
  after_create :upload_invoice

  ######################################################################
  # Validations                                                        #
  ######################################################################
  validates :order_id, uniqueness: { scope: :type }

  # The relative path of the invoice in the S3 bucket.
  #
  # @return a String, the path.
  def invoice_path
    "orders/order_#{ self.id }.pdf"
  end

  # The URL of the invoice in the S3 bucket.
  #
  # @return a String the URL.
  def S3_invoice_path
    file = CoursAvenue::Application::S3_BUCKET.objects["#{ invoice_path }"]

    file.url_for(:read).to_s
  end

  private

  # Export an order and upload it to S3.
  #
  # @return The URL of the exported order.
  def upload_invoice
    @order       = self
    @structure   = self.structure

    file    = CoursAvenue::Application::S3_BUCKET.objects["#{ invoice_path }"]
    invoice = ApplicationController.new.render_to_string('pro/structures/orders/export.pdf.haml',
                                                         pdf:    "#{ invoice_path }",
                                                         layout: 'pdf.html.haml',
                                                         locals: { :@order => @order, :@structure => @structure } )
    pdf = WickedPdf.new.pdf_from_string(invoice)
    file.write(pdf)
    file.url_for(:read).to_s
  end
  handle_asynchronously :upload_invoice

end
