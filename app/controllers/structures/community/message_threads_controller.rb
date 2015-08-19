class Structures::Community::MessageThreadsController < ApplicationController
  skip_before_filter :verify_authenticity_token
  before_filter :load_structure_and_community

  def index
    @message_threads = @community.message_threads.includes(:conversation)

    respond_to do |format|
      format.html { redirect_to structure_path(@structure) }
      format.json { render json: @message_threads, each_serializer: Community::MessageThreadsSerializer }
    end
  end

  def show
    @user             = User.where(token: params[:user_token]).first
    @message_thread   = @community.message_threads.find(params[:id])
    @question_message = @message_thread.messages.order('created_at ASC').first
    @sender           = @question_message.sender
  end

  # New comment.
  def create
    if reply_parameters[:message].present?
      message_thread = @community.ask_question!(current_user, reply_parameters[:message], thread_parameters[:indexable_card_id])
    end
    respond_to do |format|
      if message_thread and message_thread.persisted?
        format.html { redirect_to structure_path(@structure), notice: 'Votre question a été envoyée avec succés.' }
        format.json do
          render json: Community::MessageThreadsSerializer.new(message_thread)
        end
      else
        format.html { redirect_to structure_path(@structure), error: 'Une erreur est survenue, veuillez rééssayer.' }
        format.json do
          render json: { success: false,
                         formats: [:html] },
          status: :unprocessable_entity
        end
      end
    end
  end

  # Reply to a comment.
  def update
    @message_thread = @community.message_threads.find(params[:id])

    # If coming from show page, we pass the user token
    if params[:user] and params[:user][:token].present?
      @user = User.where(token: params[:user][:token]).first
    else
      @user = current_user
    end
    thread = @message_thread.reply!(@user, reply_parameters[:message]) if @user and reply_parameters[:message].present?
    respond_to do |format|
      format.html { redirect_to structure_path(@structure, anchor: "thread-#{@message_thread.id}"), notice: 'Merci pour votre réponse !' }
      format.json { render json: Community::MessageThreadsSerializer.new(@message_thread) }
    end
  end

  private

  def thread_parameters
    params.require(:community_message_thread).permit(:message, :indexable_card_id)
  end

  def reply_parameters
    params.require(:community_message_thread).permit(:message, :indexable_card_id)
  end

  def load_structure_and_community
    @structure = Structure.includes(:community).friendly.find(params[:structure_id])
    @community = @structure.community || @structure.create_community
  end
end
