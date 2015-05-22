class StructureWebsite::ParticipationRequestsController < StructureWebsiteController
  include ConversationsHelper

  layout 'structure_websites/empty'

  skip_before_filter  :verify_authenticity_token, only: [:create]

  # For an example of a message controller see:
  # https://github.com/ging/social_stream/blob/master/base/app/controllers/messages_controller.rb
  def create
    @user              = User.where(email: request_params[:user][:email].downcase).first_or_initialize(validate: false)
    @user.phone_number = request_params[:user][:phone_number]
    @user.first_name   = request_params[:user][:name]
    @user.save(validate: false)

    if request_params[:stripe_token].present?
      @user.create_stripe_customer(request_params[:stripe_token])
    end

    @structure.create_or_update_user_profile_for_user(@user, UserProfile::DEFAULT_TAGS[:contacts])
    @participation_request = ParticipationRequest.create_and_send_message request_params.merge(from_personal_website: true), @user
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

  def show
    @participation_request = @structure.participation_requests.where(token: params[:id]).first
    if @participation_request.nil?
      redirect_to structure_website_presentation_path
      return
    end
    @user = @participation_request.user
  end

  private

  def request_params
    params.require(:participation_request).permit(:course_id,
                                                  :planning_id,
                                                  :date,
                                                  :structure_id,
                                                  :stripe_token,
                                                  participants_attributes: [ :price_id, :number ],
                                                  user: [ :phone_number, :email, :name ],
                                                  message: [ :body ])
  end
end
