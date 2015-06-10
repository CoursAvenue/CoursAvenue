class StructureWebsite::Structures::GiftCertificateVouchersController < StructureWebsiteController

  before_filter :load_structure

  def index
    @gift_certificates = @structure.gift_certificates.decorate
    @voucher           = GiftCertificate::Voucher.new
  end

  def show
    @voucher          = GiftCertificate::Voucher.find(params[:id])
    @gift_certificate = @voucher.gift_certificate
  end

  def create
    gift_certificate = @structure.gift_certificates.find(voucher_params[:gift_certificate_id])

    @voucher = gift_certificate.vouchers.build(voucher_params)
    @voucher.user = User.create_or_find_from_email(voucher_params[:email], voucher_params[:name])
    @voucher.save

    token = voucher_params[:stripe_token]
    if @voucher.persisted?
      @voucher.charge!(token)
    end

    respond_to do |format|
      if @voucher.persisted? and @voucher.charged?
        format.html { redirect_to structure_website_structure_gift_certificate_voucher_path(@structure, @voucher),
                      notice: 'Votre Bon cadeau a été créé avec succés.' }
      else
        format.html { redirect_to structure_website_structure_gift_certificate_vouchers_path(@structure),
                      error: 'Une erreur est survenue lors de la création de votre bon cadeau, veuillez rééssayer.' }
      end
    end
  end

  private

  def load_structure
    @structure = Structure.friendly.find(params[:structure_id])
  end

  def voucher_params
    params.require(:gift_certificate_voucher).permit(:gift_certificate_id, :name, :email, :stripe_token)
  end
end
