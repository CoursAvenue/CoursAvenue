class Pro::Structures::MailingListsController < ApplicationController
  include ApplicationHelper

  before_action :authenticate_pro_admin!
  before_action :set_structure

  def edit
    @mailing_list = @structure.mailing_lists.find params[:id]
    render layout: false
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
    @structure  = Structure.find(params[:structure_id])
  end


  def required_params
    params.require(:mailing_list).permit(:all_profiles)
  end
end
