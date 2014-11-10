class ReplyTokenController < ApplicationController
  def show
    @reply_token = ReplyToken.find params[:id]
  end
end
