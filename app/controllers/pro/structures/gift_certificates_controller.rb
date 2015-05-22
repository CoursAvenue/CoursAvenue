class Pro::Structures::GiftCertificatesController < ApplicationController
  before_action :authenticate_pro_admin!, :set_structure
  load_and_authorize_resource :structure, find_by: :slug

  layout 'admin'

  def index
    @gift_certificates = @structure.gift_certificates.decorate
  end

  def new
    @gift_certificate = @structure.gift_certificates.new

    if request.xhr?
      render layout: false
    end
  end

  def edit
    @gift_certificate = @structure.gift_certificates.find(params[:id])

    if request.xhr?
      render layout: false
    end
  end

  def create
    @gift_certificate = @structure.gift_certificates.new(gift_certificate_params)

    respond_to do |format|
      if @gift_certificate.save
        format.html { redirect_to pro_structure_gift_certificates_path(@structure),
                      notice: 'Votre bon cadeau a été créé avec succés.' }
        format.js
      else
        format.html { render action: :new }
        format.js
      end
    end
  end

  def update
    @gift_certificate = @structure.gift_certificates.find(params[:id])

    respond_to do |format|
      if @gift_certificate.update_attributes(gift_certificate_params)
        format.html { redirect_to pro_structure_gift_certificates_path(@structure),
                      notice: 'Votre bon cadeau a été mis a jour avec succés.' }
        format.js
      else
        format.html { render action: :new }
        format.js
      end
    end
  end

  def destroy
    @gift_certificate = @structure.gift_certificates.find(params[:id])

    respond_to do |format|
      if @gift_certificate.destroy
        format.html { redirect_to pro_structure_gift_certificates_path(@structure),
                      notice: 'Le bon cadeau a été supprimé avec succés' }
      else
        format.html { redirect_to pro_structure_gift_certificates_path(@structure),
                      error: 'Erreur lors de la suppression du bon cadeau, veuillez rééssayer.' }
      end
    end
  end

  private

  def set_structure
    @structure = Structure.friendly.find(params[:structure_id])
  end

  def gift_certificate_params
    params.require(:gift_certificate).permit(:name, :amount, :description)
  end
end
