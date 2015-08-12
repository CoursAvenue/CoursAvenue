class Structures::Community::MessageThreadsController < ApplicationController
  skip_before_filter :verify_authenticity_token
  before_filter :load_structure_and_community

  def index
    @message_threads = @community.message_threads

    threads = ActiveModel::ArraySerializer.new(@message_threads,
                                               each_serializer: Community::MessageThreadsSerializer)

    respond_to do |format|
      format.html { redirect_to structure_path(@structure) }
      format.json { render json: threads }
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
    message = StringHelper.replace_contact_infos(thread_parameters[:message])

    message_thread = @community.ask_question!(current_user, message) if message.present?

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

    message = StringHelper.replace_contact_infos(reply_parameters[:message])
    # If coming from show page, we pass the user token
    if params[:user][:token].present?
      @user = User.where(token: params[:user][:token]).first
    else
      @user = current_user
    end
    thread = @message_thread.reply!(@user, message) if @user
    respond_to do |format|
      format.html { redirect_to structure_path(@structure), notice: 'Merci pour votre réponse !' }
      format.json { render json: Community::MessageThreadsSerializer.new(@message_thread) }
    end
  end

  private

  def thread_parameters
    params.require(:community_message_thread).permit(:message)
  end

  def reply_parameters
    params.require(:community_message_thread).permit(:message)
  end

  def load_structure_and_community
    @structure = Structure.includes(community: [:message_threads]).friendly.find(params[:structure_id])
    @community = @structure.community || @structure.create_community
  end
end
