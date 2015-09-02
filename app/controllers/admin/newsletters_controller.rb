class Admin::NewslettersController < ApplicationController
  before_action :authenticate_pro_super_admin!
  layout 'admin'

  def index
    if params[:sent]
      @newsletters = Newsletter.sent.order('created_at DESC').page(params[:page] || 1)
    else
      @newsletters = Newsletter.order('created_at DESC').page(params[:page] || 1)
    end
  end
end
