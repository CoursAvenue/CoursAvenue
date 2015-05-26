class StructureWebsite::GiftCertificatesController < StructureWebsiteController
  def index
    @gift_certificates = @structure.gift_certificates.decorate
    @voucher           = GiftCertificate::Voucher.new
  end

  def show
    @voucher = GiftCertificate::Voucher.find(params[:id])
  end

  def create
    gift_certificate = @structure.gift_certificates.find(voucher_params[:gift_certificate_id])

    @voucher = gift_certificate.vouchers.build(voucher_params)
    @voucher.user = User.create_or_find_from_email(voucher_params[:email], voucher_params[:name])

    respond_to do |format|
      if @voucher.save
        format.hmtl { redirect_to structure_website_gift_certificates_path, notice: 'Votr' }
      else
        format.hmtl { redirect_to structure_website_gift_certificates_path, error: '' }
      end
    end
  end

  private

  def voucher_params
    params.require(:gift_certificate_voucher).permit(:gift_certificate_id, :name, :email)
  end
end
