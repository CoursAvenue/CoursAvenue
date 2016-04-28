# encoding: utf-8
class Pro::Structures::CommentsController < Pro::ProController
  before_action :authenticate_pro_admin!

  load_and_authorize_resource :structure, find_by: :slug

  layout 'admin'

  # GET structure/:structure_id/avis/
  def index
    @comments                      = @structure.comments.accepted.page(params[:page] || 1).per(15)
    @waiting_for_deletion_comments = @structure.comments.waiting_for_deletion
  end

  # GET structure/:structure_id/avis/livre-d-or
  def comments_on_website
  end

  def highlight
    @comment   = @structure.comments.friendly.find comment_params[:id]
    @structure.highlight_comment! @comment
    redirect_to pro_structure_comments_path(@structure), notice: "Le titre de l'avis a bien été utilisé en accroche"
  end

  def ask_for_deletion
    @comment   = @structure.comments.friendly.find comment_params[:id]
    @comment.ask_for_deletion!(comment_params[:deletion_reason])
    redirect_to pro_structure_comments_path(@structure), notice: "L'avis est en attente de suppression"
  end

  def destroy
    @comment = @structure.comments.friendly.find(comment_params[:id])
    respond_to do |format|
      if @comment.destroy
        format.html { redirect_to pro_structure_comments_path(@structure), notice: 'Votre avis a bien été supprimé' }
      else
        format.html { redirect_to request.referrer || root_path, alert: 'Vous ne pouvez pas supprimer ce avis' }
      end
    end
  end

  def all
    @comments = @structure.comments
  end

  private

  def comment_params
    params.permit(:id, :structure_id, :deletion_reason)
  end
end
