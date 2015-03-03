class Order < ActiveRecord::Base
  acts_as_paranoid

  attr_accessible :type, :order_id, :amount, :structure, :subscription_plan, :promotion_code_id

  belongs_to   :structure
  belongs_to   :user
  belongs_to   :subscription_plan
  belongs_to   :promotion_code

  ######################################################################
  # Callbacks                                                          #
  ######################################################################
  after_create :upload_invoice

  ######################################################################
  # Validations                                                        #
  ######################################################################
  validates :order_id, uniqueness: { scope: :type }

  def public_order_id
    order_number = (self.structure || self.user).orders.order('created_at ASC').index(self) + 1
    "FR#{self.created_at.to_date.year}_#{self.created_at.to_date.month}_#{self.created_at.to_date.day}_#{(self.structure || self.user).id}#{order_number}"
  end

  # The relative path of the invoice in the S3 bucket.
  #
  # @return a String, the path.
  def invoice_path
    "orders/#{ self.public_order_id }.pdf"
  end

  # The URL of the invoice in the S3 bucket.
  #
  # @return a String the URL.
  def S3_invoice_path
    file = CoursAvenue::Application::S3_BUCKET.objects[ invoice_path ]

    file.url_for(:read, expires: 10.years.from_now).to_s
  end

  def order_template
    raise 'You should implement it!'
  end

  # Export an order and upload it to S3.
  #
  # @return The URL of the exported order.
  def upload_invoice
    @order       = self
    @structure   = self.structure
    @user        = self.user

    file    = CoursAvenue::Application::S3_BUCKET.objects[ invoice_path ]
    invoice = ApplicationController.new.render_to_string(order_template,
                                                         layout: 'layouts/pdf.html.haml',
                                                         locals: { :@order => @order, :@structure => @structure , :@user => @user } )
    pdf = WickedPdf.new.pdf_from_string(invoice)
    file.write(pdf)
    file.url_for(:read, expires: 10.years.from_now).to_s
  end
  handle_asynchronously :upload_invoice

end
