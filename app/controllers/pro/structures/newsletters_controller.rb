class Pro::Structures::NewslettersController < ApplicationController
  before_action :authenticate_pro_admin!
  before_action :set_structure
  before_action :set_layouts, only: [:new, :edit]

  layout 'admin'

  def index
    @newsletters = @structure.newsletters
  end

  def new
  end

  def show
    @newsletter = @structure.newsletters.includes(:blocs).find params[:id]
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
        format.html { redirect_to pro_structure_newsletters_path(@newsletter), notice: 'Supprimé' }
      else
        format.html { redirect_to pro_structure_newsletters_path(@newsletter), notice: 'Error' }
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
    @newsletter = @structure.newsletter.includes(:blocs).find params[:id]

    newsletter = NewsletterMailer.preview(@newsletter)
    mail_inliner = Roadie::Rails::MailInliner.new(newsletter, Rails.application.config.roadie)
    mail = mail.mail_inliner.execute

    @body = mail.html_part.decoded
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
    params.require(:newsletter).permit(:title, :layout_id, :blocs_attributes)
  end
end
