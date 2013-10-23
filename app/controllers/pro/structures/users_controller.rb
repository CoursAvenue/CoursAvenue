# encoding: utf-8
class Pro::Structures::UsersController < Pro::ProController
  before_action      :authenticate_pro_admin!
  load_and_authorize_resource :structure, find_by: :slug

  def index
  end

  def destroy
    @structure = Structure.friendly.find params[:structure_id]
    @user   = @structure.users.find params[:id]
    respond_to do |format|
      if current_pro_admin.super_admin? and @user.destroy
        format.html { redirect_to pro_structure_users_path(@structure), notice: 'Élève supprimé'}
      else
        format.html { redirect_to pro_structure_users_path(@structure), alert: "Vous ne pouvez pas supprimer cet élève"}
      end
    end
  end
end
