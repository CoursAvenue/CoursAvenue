class Pro::Structures::Newsletters::MailingListsController < ApplicationController
  before_action :authenticate_pro_admin!
  before_action :set_structure_and_newsletter

  def file_import
  end

  def bulk_import
  end

  private

  def set_structure_and_newsletter
    @structure  = Structure.find(params[:structure_id])
    @newsletter = @structure.newsletters.find(params[:newsletter_id])
  end
end
