# encoding: utf-8
class Pro::Structures::UserProfileImportsController < ApplicationController
  before_action :authenticate_pro_admin!
  before_action :load_structure

  layout 'admin'

  def new
    @user_profile_import = @structure.user_profile_imports.build
    session[:newsletter_id] = params[:newsletter_id] if params[:newsletter_id].present?
  end

  def choose_headers
    @user_profile_import = @structure.user_profile_imports.find(params[:id])
  end

  def create
    @user_profile_import           = @structure.user_profile_imports.build
    if params[:user_profile_import].present?
      @file = params[:user_profile_import][:file]

      @user_profile_import.data      = @file.open.read.force_encoding('BINARY')
      # @user_profile_import.data      = @file.open.read
      @user_profile_import.filename  = @file.original_filename
      @user_profile_import.mime_type = @file.content_type
    end
    @user_profile_import.structure = @structure
    respond_to do |format|
      if @user_profile_import.save
        format.html { redirect_to choose_headers_pro_structure_user_profile_import_path(@structure, @user_profile_import) }
      else
        format.html { render :new }
      end
    end
  end

  def import
    @user_profile_import      = @structure.user_profile_imports.find(params[:id])
    # Replace old file by new file if the users wants to
    @user_profile_import.file = params[:user_profile_import][:file] if params[:user_profile_import] && params[:user_profile_import][:file].present?

    if params[:table_indexes].present?
      params.delete(:table_indexes).reject(&:blank?).each do |table_index|
        attribute_name, index = table_index.split(':')
        @user_profile_import.send("#{attribute_name}_index=", index.to_i)
      end
    end
    @user_profile_import
    if @user_profile_import.import
      if session[:newsletter_id].present?
        newsletter = @structure.newsletters.find(session[:newsletter_id])
        redirect_to mailing_list_pro_structure_newsletter_path(@structure, newsletter), notice: "Import du carnet d'adresse terminé"
      else
        redirect_to pro_structure_user_profiles_path(@structure), notice: "Import du carnet d'adresse terminé"
      end
    else
      render :choose_headers
    end
  end

  private

  def load_structure
    @structure = Structure.friendly.find params[:structure_id]
  end
end
