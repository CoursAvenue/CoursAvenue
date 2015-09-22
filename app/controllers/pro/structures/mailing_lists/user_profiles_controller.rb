class Pro::Structures::MailingLists::UserProfilesController < ApplicationController
  include ApplicationHelper

  before_action :authenticate_pro_admin!

  def destroy
    @structure = Structure.friendly.find(params[:structure_id])
    @mailing_list = @structure.mailing_lists.find(params[:mailing_list_id])
    @user_profile = @structure.user_profiles.find(params[:id])

    @user_profile.destroy!

    respond_to do |format|
      format.js
    end
  end

end
