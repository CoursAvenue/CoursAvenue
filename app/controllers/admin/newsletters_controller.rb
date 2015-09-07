class Admin::NewslettersController < Admin::AdminController

  def index
    if params[:sent]
      @newsletters = Newsletter.sent.order('created_at DESC').page(params[:page] || 1)
    else
      @newsletters = Newsletter.order('created_at DESC').page(params[:page] || 1)
    end
  end
end
