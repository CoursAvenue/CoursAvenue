# encoding: utf-8
class Pro::ConversationsController < Pro::ProController
  before_action :authenticate_pro_admin!

  layout 'admin'

  def index
    if params[:info]
      @conversations = Conversation.where { subject == "Demande d'informations" }.order('updated_at DESC').limit(100)
    else
      @conversations = Conversation.order('updated_at DESC').limit(100)
    end
  end
end
