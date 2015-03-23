class Pro::Structures::Newsletters::MailingListsController < ApplicationController
  before_action :authenticate_pro_admin!
  before_action :set_structure_and_newsletter

  def create
    @mailing_list = @structure.mailing_lists.create permitted_params

    respond_to do |format|
      if @mailing_list.save
        format.json { render json: NewsletterMailingListSerializer.new(@mailing_list).to_json,
                           status: 201 }
      else
        format.json { render json: { errors: @mailing_list.errors.full_messages }, status: 422 }
      end
    end
  end

  private

  def set_structure_and_newsletter
    @structure  = Structure.find(params[:structure_id])
    @newsletter = @structure.newsletters.find(params[:newsletter_id])
  end

  def permitted_params
    params.require(:mailing_list).permit(:all_profiles, :filters)
  end
end
