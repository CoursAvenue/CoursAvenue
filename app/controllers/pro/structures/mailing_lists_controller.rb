class Pro::Structures::MailingListsController < ApplicationController
  include ApplicationHelper

  before_action :authenticate_pro_admin!
  before_action :set_structure

  layout 'admin'

  def index
    @mailing_lists = @structure.mailing_lists
    all_profile_list = @mailing_lists.all_profiles.first

    # Move the "all profiles" list to beginning.
    if all_profile_list.present?
      @mailing_lists = @mailing_lists.to_a
      @mailing_lists.delete(all_profile_list)
      @mailing_lists.unshift(all_profile_list)
    end

  end

  def new
    @mailing_list = @structure.mailing_lists.new

    if request.xhr?
      render layout: false
    end
  end

  def create
    @mailing_list = @structure.mailing_lists.new(mailing_list_params)
    @mailing_list.tag = @mailing_list.name
    if params[:emails].present?
      UserProfile.batch_create(@structure, params[:emails], { mailing_list_tag: @mailing_list.tag })
    end

    respond_to do |format|
      if @mailing_list.save
        format.html { redirect_to pro_structure_mailing_lists_path(@structure),
                      notice: 'Liste de diffusion enregistrée avec succés.' }
      else
        format.html { redirect_to pro_structure_mailing_lists_path(@structure),
                      error: 'Erreur lors de la création de la liste de diffusion, veuillez rééssayer.' }
      end
    end
  end

  def edit
    @mailing_list = @structure.mailing_lists.find(params[:id])

    if request.xhr?
      render layout: false
    end
  end

  def update
    @mailing_list = @structure.mailing_lists.find(params[:id])
    if params[:emails].present?
      UserProfile.batch_create(@structure, params[:emails], { mailing_list_tag: @mailing_list.tag })
    end

    respond_to do |format|
      if @mailing_list.update_attributes(mailing_list_params)
        format.html { redirect_to pro_structure_mailing_lists_path(@structure),
                      notice: 'Liste de diffusion mise à jour avec succés.' }
      else
        format.html { redirect_to pro_structure_mailing_lists_path(@structure),
                      error: 'Erreur lors de la mise à jour de la liste de diffusion, veuillez rééssayer.' }
      end
    end
  end

  def destroy
    @mailing_list = @structure.mailing_lists.find params[:id]
    respond_to do |format|
      if @mailing_list.destroy
        format.js
      else
        format.js
      end
    end
  end

  private

  def set_structure
    @structure  = Structure.friendly.find(params[:structure_id])
  end

  def mailing_list_params
    params.require(:mailing_list).permit(:name)
  end
end
