class ReplyTokenController < ApplicationController

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
  # TODO: Test for UserAgent: it should be
  #  "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/1.0 (KHTML, like Gecko; Gmail Actions)"
  def show
    # @reply_token = ReplyToken.find params[:id]
    @reply_token = ReplyToken.where(token: params[:id]).first
    head :not_found if @reply_token.nil?

    if @reply_token.still_valid?
      @reply_token.use!
      head :ok
    else
      head :unauthorized
    end
  end
end
