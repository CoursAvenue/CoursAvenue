# encoding: utf-8
class Pro::Structures::CommentNotificationsController < Pro::ProController
  before_action               :authenticate_pro_admin!
  load_and_authorize_resource :structure, find_by: :slug

  def create
    @structure      = Structure.friendly.find params[:structure_id]
    params[:emails] ||= ''
    regexp = Regexp.new(/\b[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}\b/)
    emails = params[:emails].scan(regexp).uniq
    text = '<p>' + params[:text].gsub(/\r\n/, '</p><p>') + '</p>'
    emails.each do |email|
      UsersReminder.delay.send_recommendation(@structure, text, email)
    end
    respond_to do |format|
      format.html { redirect_to params[:redirect_to] || recommendations_pro_structure_path(@structure), notice: (params[:emails].present? ? 'Vos élèves ont bien été notifiés.': nil)}
    end
  end

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
