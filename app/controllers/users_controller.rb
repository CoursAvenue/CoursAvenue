# encoding: utf-8
class UsersController < ApplicationController

  def show
    @user = User.find(params[:id])
    @courses   = @user.courses
    @plannings = @user.plannings
    @places    = @user.places
  end
end
