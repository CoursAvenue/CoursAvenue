# encoding: utf-8
class Pro::EmailingsController < Pro::ProController
  before_action :authenticate_pro_super_admin!
  before_action :set_preview, only: [:preview, :code]
  layout 'admin'

  def index
    @emailings = Emailing.all.sort
  end

  def new
    @emailing = Emailing.new
    16.times { @emailing.emailing_sections.build }
    @cards = []
  end

  def show
    @emailing = Emailing.find params[:id]
    @sections = ActiveModel::ArraySerializer.new(@emailing.emailing_sections, each_serializer: EmailingSectionSerializer)
  end

  def create
    @emailing = Emailing.new(emailing_params)

    respond_to do |format|
      if @emailing.save
        format.html { redirect_to pro_emailing_path(@emailing), notice: 'Bien enregistré' }
      else
        format.html { render action: :edit }
      end
    end
  end

  def edit
    @emailing = Emailing.find params[:id]
    @cards = @emailing.emailing_sections.flat_map(&:indexable_cards)

    count = 16 - @emailing.emailing_sections.count
    count.times { @emailing.emailing_sections.build  }
  end

  def update
    @emailing = Emailing.find params[:id]

    respond_to do |format|
      if @emailing.update_attributes params[:emailing]
        format.html { redirect_to pro_emailing_path(@emailing), notice: 'Bien enregistré' }
      else
        format.html { render action: :edit }
      end
    end
  end

  def destroy
    @emailing = Emailing.find params[:id]

    respond_to do |format|
      if @emailing.destroy
        format.html { redirect_to pro_emailings_path, notice: 'Supprimé' }
      else
        format.html { redirect_to pro_emailings_path, notice: 'Il y eu un problème' }
      end
    end
  end

  def preview
  end

  def code
  end

  def send_preview
    @emailing = Emailing.find params[:id]
    to = params[:to].present? ? params[:to] : 'contact@coursavenue.com'

    UserMailer.emailing(@emailing, to).deliver
    redirect_to pro_emailing_path(@emailing), notice: 'La previsualisation a bien été envoyée'
  end

  private

  def emailing_params
    params[:emailing][:emailing_sections_attributes].each_pair do |key, value|
      if value[:indexable_card_ids].present?
        value[:structure_ids] = ''
      end
    end

    params[:emailing]
  end

  def set_preview
    @emailing = Emailing.find params[:id]
    @email = preview_email

    render layout: false
  end

  # Create a preview of the email with inline styles thanks to Roadie.
  #
  # @return a String
  def preview_email
    email = UserMailer.emailing(@emailing)
    mail_inliner = Roadie::Rails::MailInliner.new(email, Rails.application.config.roadie)
    mail = mail_inliner.execute

    mail.html_part.decoded.gsub /http:\/\/coursavenue.com\/UNSUB_PLACEHOLDER/, '*|UNSUB|*'
  end

end
