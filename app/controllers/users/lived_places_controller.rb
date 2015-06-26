class Users::LivedPlacesController < ApplicationController
  before_action :authenticate_user!
  load_and_authorize_resource :user

  def destroy
    lived_place = @user.lived_places.find params[:id]
    respond_to do |format|
      if lived_place.destroy
        format.html { redirect_to user_passions_path(@user), notice: 'Lieu correctement supprimé' }
      else
        format.html { redirect_to user_passions_path(@user), error: "Le lieu n'a pas pu être supprimé" }
      end
    end
  end
end
