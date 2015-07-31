class Structures::Community::MessageThreadsController < ApplicationController
  def index
    @structure = Structure.includes(community: [:message_threads]).friendly.find(params[:structure_id])
    @community = @structure.community
    @message_threads = @community.message_threads

    threads = ActiveModel::ArraySerializer.new(@message_threads,
                                               each_serializer: Community::MessageThreadsSerializer)

    respond_to do |format|
      format.html { redirect_to structure_path(@structure) }
      format.json { render json: threads }
    end
  end

  # New comment.
  # TODO: Check how the Participation request get the user.
  def create
    @structure = Structure.includes(:community).friendly.find(params[:structure_id])
    @community = @structure.community
    @user      = User.find(thread_parameters[:user][:id])

    message = StringHelper.replace_contact_infos(thread_parameters[:message])

    message_thread = @community.ask_question!(@user, message)

    respond_to do |format|
      if message_thread.persisted?
        format.html { redirect_to structure_path(@structure), notice: 'Votre question a été envoyée avec succés.' }
        format.json do
          render json: { success: true,
                         # popup_to_show: render_to_string(partial: ''),
                         formats: [:html] }
        end
      else
        format.html { redirect_to structure_path(@structure), error: 'Une erreur est survenue, veuillez rééssayer.' }
        format.json do
          render json: { success: false,
                         # popup_to_show: render_to_string(partial: ''),
                         formats: [:html] },
          status: :unprocessable_entity
        end
      end
    end
  end

  # Reply to a comment.
  # TODO: Check how the Participation request get the user.
  def update
    @structure      = Structure.includes(community: [:message_threads]).friendly.find(params[:structure_id])
    @community      = @structure.community
    @message_thread = @community.find(params[:id])
    @user           = User.find(reply_parameters[:user][:id])

    message = StringHelper.replace_contact_infos(reply_parameters[:message])

    thread = @message_thread.reply!(@user, message)
  end

  private

  def thread_parameters
    params.require(:community_message_thread).permit(
      :message,
      :user => [:id],
    )
  end

  def reply_parameters
    params.require(:community_message_thread).permit(:message, :user => [:id])
  end
end
