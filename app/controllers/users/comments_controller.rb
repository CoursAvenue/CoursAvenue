# encoding: utf-8
class Users::CommentsController < ApplicationController
  include CommentsHelper

  layout 'user_profile'

  load_and_authorize_resource :user

  def index
    @user     = User.find params[:user_id]
    @comments = @user.comments
  end
end
