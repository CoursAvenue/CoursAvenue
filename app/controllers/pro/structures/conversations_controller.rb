class Pro::Structures::ConversationsController < ApplicationController
  # For an example of a conversation controller see:
  # https://github.com/ging/social_stream/blob/master/base/app/controllers/conversations_controller.rb
  before_action :authenticate_pro_admin!
  before_action :get_structure, :get_admin

  layout 'admin'

  def index
    @conversations = @admin.mailbox.conversations
  end

  def new
    @conversation = @admin.mailbox.conversations.build
    @message      = @conversation.messages.build
  end

  private

  def get_structure
    @structure     = Structure.find params[:structure_id]
  end

  def get_admin
    @admin         = @structure.main_contact
  end
end
