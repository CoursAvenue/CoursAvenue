class GiftCertificateMailer < ActionMailer::Base
  include ::ActionMailerWithTextPart
  include Roadie::Rails::Automatic
  include PricesHelper

  layout 'email'
  helper :application, :prices

  default from: 'CoursAvenue <noreply@coursavenue.com>'

  def voucher_confirmation_to_user(voucher)
    @voucher   = voucher
    @structure = voucher.structure
    @user      = voucher.user

    attachments['bon-cadeau.pdf'] = {
      content:   File.read(PDFGenerator.generate_gift_certificate_voucher(voucher)),
      mime_type: 'application/pdf'
    }

    mail to: voucher.user.email,
      subject: "Confirmation d'achat de bon cadeau - #{ @structure.name }"
  end

  def voucher_created_to_teacher(voucher)
    @voucher   = voucher
    @structure = voucher.structure
    @user      = voucher.user

    price = readable_amount(voucher.amount)

    mail to: voucher.structure.email,
      subject: "Bon cadeau acheté - #{ price }"
  end
end
