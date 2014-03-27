class Pro::Structures::MessagesController < ApplicationController
  # For an example of a message controller see:
  # https://github.com/ging/social_stream/blob/master/base/app/controllers/messages_controller.rb

  before_action :authenticate_pro_admin!
  before_action :get_structure, :get_admin

  layout 'admin'

  def new
    @message = @admin.messages.build params[:message]
    respond_to do |format|
      if request.xhr?
        format.html { render partial: 'form' }
      else
        format.html
      end
    end
  end

  def index
    @messages = @admin.messages
  end

  # A new message without conversation will create by default a new conversation.
  # This is done by default by mailboxer
  # Recipients receive only one person here
  def create
    @recipients   = @structure.user_profiles.find(params[:message][:recipients].reject(&:blank?)).map(&:user) if params[:message].has_key? :recipients
    @receipt      = @admin.send_message(@recipients, params[:message][:body], params[:message][:subject]) if  @recipients and @recipients.any?
    @conversation = @receipt.conversation if @receipt
    respond_to do |format|
      if @conversation and @conversation.persisted?
        format.html { redirect_to params[:return_to] || pro_structure_conversation_path(@structure, @conversation), notice: 'Votre message a bien été envoyé' }
      else
        @message = @admin.messages.build params[:message]
        @message.valid? # Triggers errors to appear
        @message.errors.add :recipients, :blank if @recipients.empty?
        format.html { render action: :new }
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
