class Pro::Structures::NewslettersController < ApplicationController
  before_action :authenticate_pro_admin!
  before_action :set_structure
  before_action :set_layouts, only: [:new, :edit, :choose_layout]

  layout 'admin'

  def index
    @newsletters = @structure.newsletters.includes(:mailing_list).decorate
  end

  def new
  end

  def choose_layout
    if params[:id]
      @newsletter = @structure.newsletters.find params[:id]
      @layout = @newsletter.layout_id
    end
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

    redirect_to pro_structure_newsletter_path(@structure, duplicated_newsletter), notice: 'Newsletter dupliquée avec succés.'
  end

  # Generate the newsletter as a String
  #
  # @return a String.
  def preview_newsletter
    @newsletter = @structure.newsletters.includes(:blocs).find params[:id]

    mail = NewsletterMailer.send_newsletter(@newsletter, nil)
    @body = MailerPreviewer.preview(mail)

    render layout: false
  end

  # Step 2.
  def mailing_list
    @newsletter    = @structure.newsletters.find params[:id]
    @user_profiles = @structure.user_profiles
    @tags          = @structure.user_profiles.includes(:tags).flat_map(&:tags).uniq.map(&:name)
    @mailing_lists = @structure.mailing_lists
    @mailing_list  = @structure.mailing_lists.new
  end

  # Step 2.
  # TODO: Use show more of.
  #
  def mailing_list_create
    @newsletter   = @structure.newsletters.find params[:id]
    @mailing_list = @structure.mailing_lists.new

    if params[:newsletter_mailing_list][:type] == 'all'
      @mailing_list.name = 'Tout les contacts'
      @mailing_list.all_profiles = true
    else
      @mailing_list.name = params[:newsletter_mailing_list][:name]
      @mailing_list.filters = params[:newsletter_mailing_list][:filters].map do |k, v|
        { predicate: v["predicate"], tag: v["tag"] }
      end
    end


    respond_to do |format|
      if @mailing_list.save
        @newsletter.mailing_list = @mailing_list
        @newsletter.save

        format.html { redirect_to metadata_pro_structure_newsletter_path(@structure, @newsletter),
                      notice: 'La liste de diffusion a été créé avec succés' }
      else
        format.html { redirect_to mailing_list_pro_structure_newsletter_path(@structure, @newsletter),
                      error: 'Erreur lors de la création de la liste de diffusion, veuillez rééssayer' }
      end
    end
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
