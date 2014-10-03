class Structures::ParticipationRequestsController < ApplicationController

  include ConversationsHelper

  skip_before_filter  :verify_authenticity_token, only: [:create]

  # For an example of a message controller see:
  # https://github.com/ging/social_stream/blob/master/base/app/controllers/messages_controller.rb
  def create
    @structure             = Structure.find params[:structure_id]
    @participation_request = ParticipationRequest.create params[:participation_request]
    LOL?
  end

end
