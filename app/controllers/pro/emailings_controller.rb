# encoding: utf-8
class Pro::EmailingsController < Pro::ProController
  before_action :authenticate_pro_super_admin!
  layout 'admin'

  def index
    @emailings = Emailing.all
  end

  def new
    @emailing = Emailing.new
    3.times { @emailing.emailing_sections.build }
  end

  def show
    @emailing = Emailing.find params[:id]
    @sections = ActiveModel::ArraySerializer.new(@emailing.emailing_sections, each_serializer: EmailingSectionSerializer)
  end

  def create
    @emailing = Emailing.new params[:emailing]

    respond_to do |format|
      if @emailing.save
        format.html { redirect_to pro_emailings_path, notice: 'Bien enregistré' }
      else
        format.html { render action: :edit }
      end
    end
  end

  def edit
    @emailing = Emailing.find params[:id]

    count = 3 - @emailing.emailing_sections.count
    count.times { @emailing.emailing_sections.build  }
  end

  def update
    @emailing = Emailing.find params[:id]

    respond_to do |format|
      if @emailing.update_attributes params[:emailing]
        format.html { redirect_to pro_emailings_path, notice: 'Bien enregistré' }
      else
        format.html { render action: :edit }
      end
    end
  end

  def destroy
    @emailing = Emailing.find params[:id]

    respond_to do |format|
      if @emailing.destroy
        format.html { redirect_to pro_emailing_path, notice: 'Supprimé' }
      else
        format.html { redirect_to pro_emailing_path, notice: 'Il y eu un problème' }
      end
    end
  end

  def preview
    @emailing = Emailing.find params[:id]
    @email = preview_email
  end

  def send_preview
    @emailing = Emailing.find params[:id]
    UserMailer.emailing(@emailing).deliver

    redirect_to pro_emailing_path(@emailing), notice: 'La previsualisation a bien été envoyée'
  end

  private

  # Create a preview of the email with inline styles thanks to Roadie.
  #
  # @return a String
  def preview_email
    email = UserMailer.emailing(@emailing)
    mail_inliner = Roadie::Rails::MailInliner.new(email, Rails.application.config.roadie)
    mail = mail_inliner.execute

    mail.html_part.decoded
  end

end
