class Users::PassionsController < ApplicationController
  layout 'user_profile'

  load_and_authorize_resource :user

  def index
    @practiced_passions = @user.passions.practiced
    @wanted_passions    = @user.passions.wanted
    4.times { @practiced_passions << @user.passions.build(practiced: true) }
    4.times { @wanted_passions    << @user.passions.build(practiced: true) }
  end

  def offers
  end

  def suggestions
    @passions = current_user.passions
  end

  def destroy
    @passion = @user.passions.find(params[:id])
    respond_to do |format|
      if @passion.destroy
        format.html { redirect_to user_passions_path(@user), notice: 'Passion supprimé' }
      else
        format.html { redirect_to user_passions_path(@user), notice: "La passion n'a pas pu être supprimé" }
      end
    end
  end
end
