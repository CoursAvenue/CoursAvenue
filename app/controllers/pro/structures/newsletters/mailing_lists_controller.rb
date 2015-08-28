class Pro::Structures::Newsletters::MailingListsController < ApplicationController
  include ApplicationHelper

  before_action :authenticate_pro_admin!
  before_action :set_structure_and_newsletter

  def edit
    @newsletter   = @structure.newsletters.find(params[:newsletter_id])
    @mailing_list = @structure.mailing_lists.find params[:id]
    render layout: false
  end

  def update
    @newsletter   = @structure.newsletters.find(params[:newsletter_id])
    @mailing_list = @structure.mailing_lists.find params[:id]
    if params[:emails].present?
      UserProfile.batch_create(@structure, params[:emails], { newsletter_id: @newsletter.id, mailing_list_tag: @mailing_list.tag })
    end
    respond_to do |format|
      @mailing_list.update_attributes(mailing_list_params)
      format.html { redirect_to mailing_list_pro_structure_newsletter_path(@structure, @newsletter) }
    end
  end

  def file_import
    @user_profile_import = @structure.user_profile_imports.build
    @file = params[:file]

    @user_profile_import.data      = @file.open.read.force_encoding('utf-8')
    @user_profile_import.filename  = @file.original_filename
    @user_profile_import.mime_type = @file.content_type

    @user_profile_import.structure = @structure

    saved = @user_profile_import.save
    # TODO: We only want to create the mailing list if the user_profile_import is valid.
    # Find a way to not save this twice.
    if saved
      @mailing_list = @structure.mailing_lists.create(tag: mailing_list_tag)
      @user_profile_import.mailing_list = @mailing_list
      @user_profile_import.save
    end

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

    mailing_list = NewsletterMailingListSerializer.new(@user_profile_import.mailing_list)

    respond_to do |format|
      if @user_profile_import.import
        format.json { render json: { message: "Import du carnet d'addresse terminé",
                                     mailing_list: mailing_list }, status: 201 }
      else
        format.json { render json: { message: "Erreur lors de l'association des colonnes, veuillez rééssayer." }, status: 400 }
      end
    end
  end

  def bulk_import
    emails = params[:emails]
    if emails.present?
      @mailing_list = @structure.mailing_lists.create(tag: mailing_list_tag)
      UserProfile.batch_create(@structure, params[:emails], { newsletter_id: @newsletter.id, mailing_list_tag: @mailing_list.tag })

      mailing_list = NewsletterMailingListSerializer.new(@mailing_list)
    end

    respond_to do |format|
      if emails.present?
        format.json { render json: { message: "Vos contacts sont bien importés.",
                                     mailing_list: mailing_list,
                                     total: @structure.user_profiles.count },
                                    status: 201 }
      else
        format.json { render json: { message: "Veuillez renseigner des adresses emails à importer." }, status: 400 }
      end
    end
  end

  def create
    @mailing_list = @structure.mailing_lists.new(required_params)

    respond_to do |format|
      if @mailing_list.save
        format.json { render json: NewsletterMailingListSerializer.new(@mailing_list).to_json, status: 201 }
      else
        format.json { render json: {}, status: 400 }
      end
    end
  end

  private

  def set_structure_and_newsletter
    @structure  = Structure.friendly.find(params[:structure_id])
    @newsletter = @structure.newsletters.friendly.find(params[:newsletter_id])
  end

  # Create a default mailing list tag.
  #
  # @return a String.
  def mailing_list_tag
    "Import du #{I18n.l(local_time(Time.current), format: :very_long_human)}"
  end

  def required_params
    params.require(:mailing_list).permit(:all_profiles)
  end

  def mailing_list_params
    params.require(:mailing_list).permit(:name)
  end

end
