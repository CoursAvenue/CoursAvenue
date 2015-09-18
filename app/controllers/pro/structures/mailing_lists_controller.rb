class Pro::Structures::MailingListsController < ApplicationController
  include ApplicationHelper

  before_action :authenticate_pro_admin!
  before_action :set_structure

  layout 'admin'

  def index
    @mailing_lists = @structure.mailing_lists
  end

  def new
  end

  def create
  end

  def edit
  end

  def update
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

end
