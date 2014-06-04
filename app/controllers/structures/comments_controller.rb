# encoding: utf-8
class Structures::CommentsController < ApplicationController
  include CommentsHelper
  helper :comments

  layout 'empty'

  def index
    @structure    = Structure.friendly.find(params[:structure_id])
    @comments     = @structure.comments.accepted.page(params[:page] || 1).per(5)

    respond_to do |format|
      format.html { redirect_to new_structure_comment_path(@structure) }
      format.json { render json: @comments.to_a, root: 'comments', each_serializer: CommentSerializer, meta: { total: @structure.comments.accepted.count } }
    end
  end

  def new
    @structure   = Structure.friendly.find(params[:structure_id])
    @comment     = @structure.comments.build
    @comments    = @structure.comments.accepted.reject(&:new_record?)[0..3]
  end

  def show
    @structure    = Structure.friendly.find(params[:structure_id])
    @comment      = @structure.comments.find(params[:id])
    @user         = @comment.user
    @structure_search = StructureSearch.search({ lat: @structure.latitude,
                                                 lng: @structure.longitude,
                                                 radius: 7,
                                                 per_page: 100,
                                                 bbox: true }).results

    @structure_locations = Gmaps4rails.build_markers(@structure_search.select { |s| s.latitude.present? }) do |structure, marker|
      marker.lat structure.latitude
      marker.lng structure.longitude
    end

    respond_to do |format|
      format.json { render json: @comment }
      format.html {}
    end
  end

  def create
    @commentable  = find_commentable
    @comment      = @commentable.comments.build params[:comment]

    # If current user exists, affect it to the comment
    if current_user
      @comment.author_name = current_user.name
      @comment.email       = current_user.email
    else
      user_email = params[:comment][:email].downcase
      # If the user does not exists
      unless (@user = User.where(email: user_email).first)
        @user = User.new email: user_email, first_name: params[:comment][:author_name]
      end
      @user.update_attribute(:first_name, params[:comment][:author_name]) if params[:comment][:author_name].present?
    end
    @comment.user = @user || current_user
    respond_to do |format|
      if @comment.save
        send_private_message unless params[:private_message].blank?
        cookies[:delete_cookies] = true
        if params[:return_to] && params[:return_to] == 'recommendation-page'
          format.html { redirect_to structure_comment_path(@comment.commentable, @comment), notice: "Merci d'avoir laissé votre avis !" }
        else
          format.html { redirect_to (request.referrer || commentable_path(@comment)), notice: "Merci d'avoir laissé votre avis !" }
        end
      else
        @structure    = @commentable
        @comments     = @structure.comments.accepted.reject(&:new_record?)[0..5]
        flash[:alert] = "L'avis n'a pas pu être posté. Assurez-vous d'avoir bien rempli tous les champs."
        format.html { render 'structures/comments/new' }
      end
    end
  end

  private

  def send_private_message
    @recipient    = @comment.structure.main_contact
    @receipt      = @comment.user.send_message_with_label(@recipient, params[:private_message], (params[:subject].present? ? params[:subject] : 'Message personnel suite à ma recommandation'), 'comment')
    @conversation = @receipt.conversation
  end

  def find_commentable
    type = params[:comment][:commentable_type]
    raise "Unknown commentable type" unless %w(Structure).include?(type)
    type.classify.constantize.find(params[:comment][:commentable_id])
  end

end
