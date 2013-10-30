# encoding: utf-8
class Pro::MessagesController < Pro::ProController
  before_action :authenticate_pro_admin!

  layout 'admin'

  def index
    @messages = Message.order('created_at DESC').limit(100)
  end
end
