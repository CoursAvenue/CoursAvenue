class Pro::Structures::ConversationsController < ApplicationController
  # For an example of a conversation controller see:
  # https://github.com/ging/social_stream/blob/master/base/app/controllers/conversations_controller.rb
  before_action :authenticate_pro_admin!
  load_and_authorize_resource :structure
  before_action :get_structure, :get_admin

  include ConversationsHelper

  layout 'admin'

  # Set the message as treated_by_phone. It means that the admin don't have to
  # answer it to be it counted as treated when computing score
  def treat_by_phone
    @conversation = @admin.mailbox.conversations.find(params[:id])
    @conversation.update_column :treated_by_phone, true
    @conversation.update_column :treated_at, Time.now
    @conversation.update_column :updated_at, Time.now
    @structure.delay.compute_response_time
    @structure.delay.compute_response_rate
    respond_to do |format|
      format.html { redirect_to pro_structure_conversations_path(@structure), notice: "La demande est considérée comme traitée" }
    end
  end

  # Flag message and set the label to be a conversation
  def flag
    @conversation = @admin.mailbox.conversations.find(params[:id])
    @conversation.update_column :flagged, params[:flag]
    @conversation.update_column :flagged_at, Time.now
    @conversation.update_column :mailboxer_label_id, Mailboxer::Label::CONVERSATION
    @structure.delay.compute_response_time
    @structure.delay.compute_response_rate
    respond_to do |format|
      format.html { redirect_to pro_structure_conversations_path(@structure), notice: "Le message a été signalé" }
    end
  end

  def show
    @conversation = @admin.mailbox.conversations.find(params[:id])
    @conversation.mark_as_read(@admin)
    @participation_request = conversation_participation_request(@conversation)
    @is_xhr = request.xhr?
    respond_to do |format|
      if @participation_request and !@participation_request.past?
        format.html { redirect_to pro_structure_participation_request_path(@structure, @participation_request) }
      elsif request.xhr?
        format.html { render layout: false }
      else
        format.html
      end
    end
  end

  def index
    if params[:conversation_label_id].present?
      @conversations = @admin.mailbox.conversations.where(mailboxer_label_id: params[:conversation_label_id])
    elsif @admin
      @conversations = @admin.mailbox.conversations
    else
      @conversations = []
    end
    @conversations = Kaminari.paginate_array(@conversations).page(params[:page] || 1).per(15)
  end

  def new
    @conversation = @admin.mailbox.conversations.build
  end

  def update
    params[:conversation][:message][:body] = StringHelper.replace_contact_infos(params[:conversation][:message][:body]) unless params[:conversation][:message][:body].blank?

    @conversation    = @admin.mailbox.conversations.find params[:id]

    if @structure.community.present? and @structure.community.message_threads.any?
      message_thread = @structure.community.message_threads.where(mailboxer_conversation_id: @conversation.id).first
      message_thread.reply!(@admin, params[:conversation][:message][:body])
    else
      @admin.reply_to_conversation(@conversation, params[:conversation][:message][:body]) unless params[:conversation][:message][:body].blank?
      if @conversation.participation_request_id.present?
          pr = ParticipationRequest.where(id: @conversation.participation_request_id).first
          pr.treat!('message') if pr.present?
      end
    end
    respond_to do |format|
      if params[:conversation][:message][:body].blank?
        format.html { redirect_to pro_structure_conversation_path(@structure, @conversation), error: 'Vous devez mettre un text pour répondre' }
        format.js
      else
        format.html { redirect_to pro_structure_conversation_path(@structure, @conversation) }
        format.js
      end
    end
  end

  private

  def get_structure
    @structure = Structure.friendly.find params[:structure_id]
  end

  def get_admin
    @admin = @structure.main_contact
  end
end
