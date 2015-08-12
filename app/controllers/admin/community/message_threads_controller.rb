class Admin::Community::MessageThreadsController < ApplicationController
  before_action :authenticate_pro_super_admin!

  layout 'admin'

  def index
    @message_threads = Community::MessageThread.order('created_at DESC').page(params[:page] || 1)
  end
end
