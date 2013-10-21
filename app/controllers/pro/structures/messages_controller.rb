class Pro::Structures::MessagesController < ApplicationController
  # For an example of a message controller see:
  # https://github.com/ging/social_stream/blob/master/base/app/controllers/messages_controller.rb

  before_action :authenticate_pro_admin!
  before_action :get_structure, :get_admin

  layout 'admin'

  def new
    @message = @admin.messages.build
  end

  def index
    @messages = @admin.messages.build
  end

  def create
    @recipient = User.where(email: params[:recipient_email]).first
    @receipt   = get_admin.send_message(@recipient, params[:message][:body], "Réponse à votre avis")
    @conversation = @receipt.conversation
    respond_to do |format|
      if @conversation
        render 'new'
      else
        format.html { redirect_to pro_structure_conversation_path(get_structure, @conversation) }
      end
    end
  end

  private

  def get_structure
    @structure = Structure.find params[:structure_id]
  end

  def get_admin
    @admin = @structure.main_contact
  end
end
