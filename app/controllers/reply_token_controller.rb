class ReplyTokenController < ApplicationController
  before_filter :check_user_agent

  # This is the route Google will use when a user clicks on the email action.
  #
  # On success, it should return a response code of 200 (OK).
  # Otherwise, it should return:
  # * 400 for a bad request           => Google will fail the action.
  # * 401 for an unauthorized request => Google will fail the action.
  # * 404 for a not found request     => Google will fail the action.
  # * 408 for a request timeout       => Google will retry again later.
  #
  # We start by checking the validity of the token, and then execute the
  # actions.
  def show
    begin
      @reply_token = ReplyToken.find params[:id]
    rescue ActiveRecord::RecordNotFound
      return head :not_found
    end

    if @reply_token.still_valid?
      @reply_token.use!
      head :ok
    else
      head :unauthorized
    end
  end

  private

  # Check if the request is sent by the authorized user agent.
  #
  # @return nothing
  def check_user_agent
    if request.user_agent != ReplyToken::GOOGLE_ACTION_USER_AGENT
      redirect_to root_path, alert: "Vous n'avez pas le droit !"
    end
  end
end
