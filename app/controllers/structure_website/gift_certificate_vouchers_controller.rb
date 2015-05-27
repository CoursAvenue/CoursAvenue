class StructureWebsite::GiftCertificateVouchersController < StructureWebsiteController
  def index
    @gift_certificates = @structure.gift_certificates.decorate
    @voucher           = GiftCertificate::Voucher.new
  end

  def create
    gift_certificate = @structure.gift_certificates.find(voucher_params[:gift_certificate_id])

    @voucher = gift_certificate.vouchers.build(voucher_params)
    @voucher.user = User.create_or_find_from_email(voucher_params[:email], voucher_params[:name])

    respond_to do |format|
      if @voucher.save
        format.html { redirect_to structure_website_gift_certificate_voucher_path(@voucher),
                      notice: 'Votre Bon cadeau a été créé avec succés.' }
      else
        format.html { redirect_to structure_website_gift_certificate_vouchers_path,
                      error: 'Une erreur est survenue lors de la création de votre bon cadeau, veuillez rééssayer.' }
      end
    end
  end

  private

  def voucher_params
    params.require(:gift_certificate_voucher).permit(:gift_certificate_id, :name, :email, :stripe_token)
  end
end
