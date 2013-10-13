# encoding: utf-8
class UsersController < InheritedResources::Base
  layout 'user_profile'
  actions :show, :update

  load_and_authorize_resource :user, find_by: :slug

  def show
    @user = User.find(params[:id])
  end

  def update
    update! do |format|
      format.html { redirect_to user_path(current_user), notice: 'Votre profil a bien été mis à jour.' }
    end
  end
end
