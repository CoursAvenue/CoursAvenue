class Pro::Structures::MailingListController < Pro::ProController
  def create
    structure  = Structure.find params[:structure_id]
    newsletter = structure.newsletters.find params[:newsletter_id]

    @mailing_list = structure.mailing_lists.new required_params

    respond_to do |format|
      if @mailing_list.save
        format.html { redirect_to mailing_list_pro_structure_newsletter_path(structure, newsletter),
                      notice: 'Liste de diffusion créée avec succés' }
      else
        format.html { redirect_to mailing_list_pro_structure_newsletter_path(structure, newsletter),
                      error: 'Erreur lors de la création de la list de diffusion' }
      end
    end
  end

  private

  # Use strong parameters.
  #
  # @return the permitted parameters as a Hash.
  def required_params
    params.require(:mailing_list).permit(:tag, :name)
  end
end
