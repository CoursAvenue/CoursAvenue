class Structures::Community::MessageThreadsController < ApplicationController
  def index
    @structure = Structure.includes(community: [:message_threads]).friendly.find(params[:structure_id])
    @community = @structure.community
    @message_threads = @community.message_threads

    threads = ActiveModel::ArraySerializer.new(@message_threads,
                                               each_serializer: Community::MessageThreadsSerializer)

    respond_to do |format|
      format.html { redirect_to structure_path(@structure) }
      format.json { render json: { message_threads: threads } }
    end
  end
end
