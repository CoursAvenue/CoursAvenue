class Pro::Structures::UserProfileImportsController < ApplicationController
  before_action :authenticate_pro_admin!
  before_action :load_structure

  layout 'admin'

  def new
    @user_profile_import = UserProfileImport.new
  end

  def choose_headers
    @file = params[:user_profile_import][:file]
    @user_profile_import = UserProfileImport.new(params[:user_profile_import])
  end

  def create
    #
    if params[:table_indexes].present?
      params.delete(:table_indexes).reject(&:blank?).each do |table_index|
        attribute_name, index = table_index.split(':')
        params[:user_profile_import]["#{attribute_name}_index".to_sym] = index
      end
    end
    params[:user_profile_import][:structure_id] = @structure.id
    @user_profile_import = UserProfileImport.new(params[:user_profile_import])
    if @user_profile_import.save
      redirect_to pro_structure_user_profiles_path(@structure), notice: "Imported products successfully."
    else
      render :new
    end
  end

  private

  def load_structure
    @structure = Structure.friendly.find params[:structure_id]
  end
end
