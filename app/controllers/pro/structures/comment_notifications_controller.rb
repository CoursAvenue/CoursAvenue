# encoding: utf-8
class Pro::Structures::CommentNotificationsController < Pro::ProController
  before_action               :authenticate_pro_admin!
  load_and_authorize_resource :structure, find_by: :slug

  def create
    @structure      = Structure.friendly.find params[:structure_id]
    params[:emails] ||= ''
    regexp = Regexp.new(/\b[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}\b/)
    emails = params[:emails].scan(regexp).uniq
    text = '<div class="p">' + params[:text].gsub(/\r\n\r\n/, '</div><div class="p">').gsub(/\r\n/, '<br>') + '</div>'
    emails.each do |_email|
      if (user = User.where(User.arel_table[:email].matches(_email)).first).nil?
        user             = User.force_create(email: _email)
        user.structures << @structure
        user.subjects   << @structure.subjects
        user.save(validate: false)
      end
      notification           = user.comment_notifications.build structure: @structure, text: text
      notification.save
    end
    respond_to do |format|
      format.html { redirect_to params[:redirect_to] || recommendations_pro_structure_path(@structure), notice: (params[:emails].present? ? 'Vos élèves ont bien été notifiés.' : nil) }
    end
  end

  def index
    @comment_notifications     = Kaminari.paginate_array(@structure.comment_notifications).page(params[:page] || 1).per(100)
  end

  def destroy
    @structure            = Structure.friendly.find params[:structure_id]
    @comment_notification = @structure.comment_notifications.find params[:id]
    respond_to do |format|
      if current_pro_admin.super_admin? && @comment_notification.destroy
        format.html { redirect_to pro_structure_comment_notifications_path(@structure), notice: 'Élève supprimé' }
      else
        format.html { redirect_to pro_structure_comment_notifications_path(@structure), alert: 'Vous ne pouvez pas supprimer cet élève' }
      end
    end
  end
end
