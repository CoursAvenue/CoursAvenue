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
    params[:message][:recipients].reject(&:blank?) if params[:message][:recipients].is_a? Array
    @recipients   = @structure.user_profiles.find(params[:message][:recipients]) if params[:message].has_key? :recipients
    @recipients   = (@recipients.is_a?(Array) ? @recipients.map(&:user) : @recipients.user)
    @receipt      = @admin.send_message_with_label(@recipients, params[:message][:body], params[:message][:subject], Mailboxer::Label::CONVERSATION.id) if @recipients and @recipients.present? and params[:message][:body].present?
    @conversation = @receipt.conversation if @receipt
    respond_to do |format|
      if @conversation and @conversation.persisted?
        format.html { redirect_to params[:return_to] || pro_structure_conversation_path(@structure, @conversation), notice: 'Votre message a bien été envoyé' }
        format.js
      else
        @message = @admin.messages.build params[:message]
        @message.valid? # Triggers errors to appear
        @message.errors.add :recipients, :blank if @recipients.blank?
        format.html { render action: :new }
        format.js
      end
    end
  end

  private

  def get_structure
    @structure = Structure.friendly.find params[:structure_id]
  end

  def get_admin
    @admin = @structure.admin
  end
end
