# encoding: utf-8
class Users::FollowingsController < ApplicationController

  layout 'empty_user_profile'

  load_and_authorize_resource :user, find_by: :slug

  def index
    @user = User.includes(:favorites).find(params[:user_id])
  end
end
