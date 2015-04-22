class StructureWebsite::ParticipationRequestsController < ApplicationController

  include ConversationsHelper

  skip_before_filter  :verify_authenticity_token, only: [:create]

  # For an example of a message controller see:
  # https://github.com/ging/social_stream/blob/master/base/app/controllers/messages_controller.rb
  def create
    @structure = Structure.friendly.find params[:structure_id]
    @user      = User.where(email: params[:participation_request][:user][:email]).first_or_create(validate: false)
    if params[:participation_request][:user] and params[:participation_request][:user][:phone_number].present? and params[:participation_request][:user][:phone_number].length < 30
      @user.phone_number = params[:participation_request][:user][:phone_number]
      @user.save
    end
    @structure.create_or_update_user_profile_for_user(@user, UserProfile::DEFAULT_TAGS[:contacts])

    @participation_request = ParticipationRequest.create_and_send_message params[:participation_request], params[:participation_request][:message][:body], @user, @structure
    respond_to do |format|
      if @participation_request.persisted?
        format.json { render json: { succes: true,
                                     popup_to_show: render_to_string(partial: 'structure_website/participation_requests/request_sent',
                                     formats: [:html]) } }
      else
        format.json { render json: { succes: false,
                                     popup_to_show: render_to_string(partial: 'structure_website/participation_requests/request_already_sent',
                                     formats: [:html]) },
                                     status: :unprocessable_entity }
      end
    end

  end

end
