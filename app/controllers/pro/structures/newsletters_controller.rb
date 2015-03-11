class Pro::Structures::NewslettersController < ApplicationController
  before_action :authenticate_pro_admin!
  before_action :set_structure
  before_action :set_layouts, only: [:new, :edit]

  layout 'admin'

  def index
    @newsletters = @structure.newsletters.decorate
  end

  def new
  end

  def show
    @newsletter = @structure.newsletters.includes(:blocs).find params[:id]
    @blocs = @newsletter.blocs.order(:position)
  end

  def create
    @newsletter = @structure.newsletters.new params[:newsletter]

    respond_to do |format|
      if @newsletter.save
        format.html { redirect_to pro_structure_newsletter_path(@structure, @newsletter),
                      notice: 'Bien enregistré' }
      else
        format.html { render action: :edit }
      end
    end
  end

  def edit
    @newsletter = @structure.newsletters.includes(:blocs).find params[:id]
  end

  def update
    @newsletter = @structure.newsletters.includes(:blocs).find params[:id]

    respond_to do |format|
      if @newsletter.update_attributes params[:newsletter]
        format.html { redirect_to pro_structure_newsletter_path(@structure, @newsletter),
                      notice: 'Bien enregistré' }
      else
        format.html { render action: :edit }
      end
    end
  end

  # TODO: Fix error message..
  def destroy
    @newsletter = @structure.newsletters.includes(:blocs).find params[:id]

    respond_to do |format|
      if @newsletter.destroy
        format.html { redirect_to pro_structure_newsletters_path(@structure),
                      notice: 'La newsletter a été supprimée avec succés' }
      else
        format.html { redirect_to pro_structure_newsletters_path(@structure),
                      error: "Erreur lors de la suppression de la newsletter, veillez rééssayer." }
      end
    end
  end

  # TODO: (Use a service?)
  # 1. Check all of the required informations are given.
  # 2. Generate the newsletter content.
  # 3. Send the newsletter to the associated mailing list.
  def send_newsletter
    @newsletter = @structure.newsletters.includes(:blocs).find params[:id]
  end

  # Duplicate the newsletter and all associated models.
  def duplicate
    @newsletter = @structure.newsletters.includes(:blocs).find params[:id]
    duplicated_newsletter = @newsletter.duplicate!

    redirect_to duplicated_newsletter, notice: 'Newsletter dupliqué avec succés.'
  end

  # Generate the newsletter as a String
  #
  # @return a String.
  def preview_newsletter
    @newsletter = @structure.newsletter.find params[:id]

    newsletter = NewsletterMailer.preview(@newsletter)
    mail_inliner = Roadie::Rails::MailInliner.new(newsletter, Rails.application.config.roadie)
    mail = mail.mail_inliner.execute

    @body = mail.html_part.decoded
  end

  # Step 2.
  def mailing_list
    @newsletter    = @structure.newsletters.find params[:id]
    @has_contacts  = @structure.user_profiles.any?

    @mailing_lists = @structure.mailing_lists
    @mailing_list  = @structure.mailing_lists.new

    @used_tags = @structure.user_profiles.includes(:tags).flat_map(&:tags).uniq.map(&:name)
  end

  # Step 3.
  def metadata
    @newsletter = @structure.newsletters.find params[:id]
  end

  # Step 3.
  def save_and_send
    @newsletter = @structure.newsletters.find params[:id]

    respond_to do |format|
      if @newsletter.update_attributes(required_params) and NewsletterSender.send_newsletter(@newsletter)
        format.html { redirect_to pro_structure_newsletters_path(@structure),
                      notice: "Votre newsletter est en cours d'envoi" }
      else
        format.html { redirect_to metadata_pro_structure_newsletter_path(@structure, @newsletter),
                      error: "Erreur lors de la mise a jour des informations ou l'envoi de la newsletter, veillez rééssayer." }
      end
    end
  end

  private

  # Set the current structure.
  def set_structure
    @structure = Structure.find(params[:structure_id])
  end

  # Set the layouts as usable JSON.
  def set_layouts
    @layouts = Newsletter::Layout.all.as_json.map do |layout|
      layout["attributes"]
    end
  end

  # Use the strong parameters.
  #
  # @return the permitted parameters as a Hash.
  def required_params
    params.require(:newsletter).permit(:title, :layout_id, :blocs_attributes,
                                       :sender_name, :reply_to, :object)
  end
end
