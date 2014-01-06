class Users::PassionsController < ApplicationController
  layout 'user_profile'

  def index
    @practiced_passions = current_user.passions.practiced
    @wanted_passions    = current_user.passions.wanted
    4.times { @practiced_passions << current_user.passions.build(practiced: true) }
    4.times { @wanted_passions    << current_user.passions.build(practiced: true) }
  end

  def create
  end
end

