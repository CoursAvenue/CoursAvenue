class StructureWebsite::Structures::ParticipationRequestsController < StructureWebsiteController
  include ConversationsHelper

  layout 'structure_websites/empty'

  skip_before_filter :verify_authenticity_token, only: [:create]
  before_filter      :load_structure

  # For an example of a message controller see:
  # https://github.com/ging/social_stream/blob/master/base/app/controllers/messages_controller.rb
  def create
    @user              = User.where(email: request_params[:user][:email].downcase.gsub(' ', '')).first_or_initialize(validate: false)
    @user.phone_number = request_params[:user][:phone_number]
    @user.first_name   = request_params[:user][:first_name]
    @user.last_name    = request_params[:user][:last_name]
    @user.save(validate: false)

    if request_params[:stripe_token].present?
      @user.create_stripe_customer(request_params[:stripe_token])
    end

    @participation_request = ParticipationRequest.create_and_send_message request_params.merge(from_personal_website: true), @user
    respond_to do |format|
      if @participation_request.persisted?
        format.json { render json: { succes: true,
                                     popup_to_show: render_to_string(partial: 'structure_website/structures/participation_requests/request_sent',
                                     formats: [:html]) } }
      else
        format.json { render json: { succes: false,
                                     popup_to_show: render_to_string(partial: 'structure_website/structures/participation_requests/request_already_sent',
                                     formats: [:html]) },
                                     status: :unprocessable_entity }
      end
    end
  rescue Stripe::CardError => exception
    stripe_error_message = "#{I18n.t('stripe.error_codes')[exception.code.to_sym]} Veuillez rééssayer."
    respond_to do |format|
      format.json { render json: { success: false,
                                   stripe_error_message: stripe_error_message },
                                   status: :unprocessable_entity }
    end
  end

  def show
    @participation_request = @structure.participation_requests.where(token: params[:id]).first
    if @participation_request.nil?
      redirect_to structure_path(@structure)
      return
    end

    if current_user
      if current_user == @participation_request.user
        # When the connected user is the pr owner.
        redirect_to user_participation_request_path(current_user, @participation_request)
        return
      else
        # When the connected user is not the pr owner.
        redirect_to structure_path(@structure)
        return
      end
    else
      # When there's no connected user.
      @user = @participation_request.user
    end
  end

  private

  def request_params
    params.require(:participation_request).permit(:course_id,
                                                  :planning_id,
                                                  :date,
                                                  :structure_id,
                                                  :stripe_token,
                                                  participants_attributes: [ :price_id, :number ],
                                                  user: [ :phone_number, :email,
                                                          :first_name, :last_name ],
                                                  message: [ :body ])
  end

  private

  def load_structure
    @structure = Structure.friendly.find(params[:structure_id])
  end
end
