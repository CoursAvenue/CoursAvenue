class Pro::Structures::Newsletters::MailingListsController < ApplicationController
  before_action :authenticate_pro_admin!
  before_action :set_structure_and_newsletter

  def file_import
    @user_profile_import = @structure.user_profile_imports.build
    @file = params[:file]

    @user_profile_import.data      = @file.open.read.force_encoding('utf-8')
    # @user_profile_import.data      = @file.open.read
    @user_profile_import.filename  = @file.original_filename
    @user_profile_import.mime_type = @file.content_type

    @user_profile_import.structure = @structure

    saved = @user_profile_import.save

    popup_content = render_to_string(
      partial: 'pro/structures/newsletters/mailing_lists/choose_file_headers',
      locals:  { structure: @structure, user_profile_import: @user_profile_import },
      layout:  false,
      formats: [:html]
    )

    respond_to do |format|
      if saved
        format.json { render json: { popup_to_show: popup_content, user_profile_import: @user_profile_import },
                           status: 201 }
      else
        format.json { render json: { message: 'ko' }, status: 422 }
      end
    end
  end

  def update_headers
    @user_profile_import = @structure.user_profile_imports.find(params[:user_profile_import])

    if params[:table_indexes].present?
      params.delete(:table_indexes).reject(&:blank?).each do |table_index|
        attribute_name, index = table_index.split(':')
        @user_profile_import.send("#{attribute_name}_index=", index.to_i)
      end
    end

    respond_to do |format|
      if @user_profile_import.import
        format.json { render json: { message: "Import du carnet d'addresse terminé" }, status: 201 }
      else
        format.json { render json: { message: "Erreur lors de l'association des colonnes, veuillez rééssayer." }, status: 400 }
      end
    end
  end

  def bulk_import
    UserProfile.delay.batch_create(@structure, params[:emails], newsletter_id: @newsletter.id)

    respond_to do |format|
      if params[:email].present?
        format.json { render json: { message: "L'import est en cours, nous vous enverrons un mail dès l'import terminé." }, status: 201 }
      else
        format.json { render json: { message: "Veuillez renseigner des adresses emails à importer." }, status: 400 }
      end
    end
  end

  private

  def set_structure_and_newsletter
    @structure  = Structure.find(params[:structure_id])
    @newsletter = @structure.newsletters.find(params[:newsletter_id])
  end
end
