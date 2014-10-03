# encoding: utf-8
class Structures::CommentsController < ApplicationController
  include CommentsHelper
  helper :comments

  layout :get_layout

  def index
    @structure    = Structure.friendly.find(params[:structure_id])
    @comments     = @structure.comments.accepted.page(params[:page] || 1).per(5)

    respond_to do |format|
      format.html { redirect_to new_structure_comment_path(@structure) }
      format.json { render json: @comments.to_a, root: 'comments', each_serializer: CommentSerializer, meta: { total: @structure.comments.accepted.count }, options: { structure: @structure } }
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
    @structure = Structure.friendly.find(params[:structure_id])
    @comment   = @structure.comments.build params[:comment]

    # If current user exists, affect it to the comment
    if current_user
      @comment.author_name = current_user.name
      @comment.email       = current_user.email
      @user                = current_user
    else
      user_email = params[:comment][:email].try(:downcase)
      # If the user does not exists
      unless (@user = User.where(email: user_email).first)
        @user = User.new email: user_email, first_name: params[:comment][:author_name]
      end
      @user.update_attribute(:first_name, params[:comment][:author_name]) if params[:comment][:author_name].present?
    end
    if @comment.subjects.any?
      @user.subjects << @comment.subjects
    else
      @user.subjects << @comment.structure.subjects
    end
    @user.save
    @comment.user = @user
    respond_to do |format|
      if @comment.valid? and params[:private_message].present?
        create_private_message
      end
      if @comment.save
        cookies[:delete_cookies] = true
        format.html { redirect_to structure_comment_path(@structure, @comment), notice: "Merci d'avoir laissé votre avis !" }
      else
        @comments     = @structure.comments.accepted.reject(&:new_record?)[0..5]
        flash[:alert] = "L'avis n'a pas pu être posté. Assurez-vous d'avoir bien rempli tous les champs."
        format.html { render 'structures/comments/new' }
      end
    end
  end

  private

  def create_private_message
    @recipient    = @comment.structure.main_contact
    @receipt      = @comment.user.send_message_with_label(@recipient,
                                                          params[:private_message],
                                                          (params[:subject].present? ? params[:subject] : 'Message personnel suite à ma recommandation'),
                                                          Mailboxer::Label::COMMENT.id)
    @conversation = @receipt.conversation
    @comment.associated_message_id = @conversation.messages.first.id
  end

  def get_layout
    if action_name == 'show'
      'pages'
    else
      'empty'
    end
  end
end
