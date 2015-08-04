# encoding: utf-8
class Structures::CommentsController < ApplicationController
  include CommentsHelper
  helper :comments

  layout :get_layout

  def index
    @structure    = Structure.friendly.find(params[:structure_id])
    if params[:certified] == "true"
      @comments = @structure.comments.accepted.certified.page(params[:page] || 1).per(5)
    elsif params[:certified] == "false"
      @comments = @structure.comments.accepted.not_certified.page(params[:page] || 1).per(5)
    else
      @comments = @structure.comments.accepted.page(params[:page] || 1).per(5)
    end

    respond_to do |format|
      format.html { redirect_to new_structure_comment_path(@structure) }
      format.json { render json: @comments.to_a,
                           root: 'comments',
                           each_serializer: CommentSerializer,
                           meta: { total: @comments.total_count, total_pages: @comments.total_pages },
                           options: { structure: @structure } }
    end
  end

  def new
    @structure = Structure.friendly.find(params[:structure_id])
    if params[:participation_request_id]
      @participation_request = @structure.participation_requests.find(params[:participation_request_id])
    end
    @comment        = @structure.comments.build
    @comments       = @structure.comments.accepted.reject(&:new_record?)[0..3]

    mixpanel_tracker.track("Avis: #{params[:utm_campaign]}", { etape: params[:utm_medium], structure_slug: @structure.slug, structure_name: @structure.name } )
  end

  def show
    @structure    = Structure.friendly.find(params[:structure_id])
    @comment      = Comment::Review.find(params[:id])
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
    # In case the validation fails, we want to have the `@participation_request`
    @structure             = Structure.friendly.find(params[:structure_id])
    @participation_request = @structure.participation_requests.find(params[:participation_request_id]) if params[:participation_request_id].present?
    @comment               = @structure.comments.build params[:comment]

    @user = create_user(params[:comment])

    @comment.user = @user
    respond_to do |format|
      if @comment.valid? and params[:private_message].present?
        create_private_message
      end
      if @comment.save
        cookies[:delete_cookies] = true
        mixpanel_tracker.track("Avis: saved", { user: @user.id, comment: @comment.id })
        format.html { redirect_to pages_what_is_it_path, notice: "Merci d'avoir laissé votre avis !" }
      else
        @comments     = @structure.comments.accepted.reject(&:new_record?)[0..5]
        flash[:alert] = "L'avis n'a pas pu être posté. Assurez-vous d'avoir bien rempli tous les champs."
        format.html { render 'structures/comments/new' }
      end
    end
  end

  def create_from_email
    comment_params = {}
    params.each do |name, value|
      comment_params[name.split('comment_').last] = value if name.starts_with? 'comment_'
    end
    @structure = Structure.friendly.find(params[:structure_id])
    # In case the validation fails, we want to have the `@participation_request`
    @participation_request = @structure.participation_requests.find(params[:participation_request_id]) if params[:participation_request_id].present?
    subject_ids = comment_params.delete(:subject_ids)
    @comment   = @structure.comments.build comment_params
    @comment.subjects = Subject.find subject_ids.split(',') if subject_ids
    mixpanel_tracker.track('Avis: from_mail', { structure_slug: @structure.slug, structure_name: @structure.name })

    @user = create_user(comment_params)
    @comment.user = @user
    respond_to do |format|
      if @comment.save
        format.html { redirect_to add_private_message_structure_comment_path(@structure, @comment),
                      notice: "Merci d'avoir laissé votre avis !" }
        mixpanel_tracker.track('Avis: saved', { user: @user.id, comment: @comment.id })
      else
        @comments     = @structure.comments.accepted.reject(&:new_record?)[0..5]
        flash[:alert] = "L'avis n'a pas pu être posté. Assurez-vous d'avoir bien rempli tous les champs."
        format.html { render 'structures/comments/new', notice: "Merci d'avoir laissé votre avis !" }
      end
    end
  end

  def add_private_message
    @structure = Structure.friendly.find(params[:structure_id])
    @comment   = Comment.find params[:id]
    @comments  = @structure.comments.accepted.reject(&:new_record?)[0..3]
  end

  def update
    @comment = Comment.find params[:id]
    if params[:private_message].present? and @comment.associated_message.nil?
      create_private_message
    end
    respond_to do |format|
      format.html { redirect_to pages_what_is_it_path, notice: "Merci d'avoir laissé votre avis !" }
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

  def create_user(comment_params)
    # If current user exists, affect it to the comment
    if current_user
      @comment.author_name = current_user.name
      @comment.email       = current_user.email
      @user                = current_user
    else
      user_email = comment_params[:email].try(:downcase)
      # If the user does not exists
      unless (@user = User.where(email: user_email).first)
        @user = User.new email: user_email, first_name: comment_params[:author_name]
      end
      @user.update_attribute(:first_name, comment_params[:author_name]) if comment_params[:author_name].present?
    end
    if @comment.subjects.any?
      @user.subjects << @comment.subjects
    else
      @user.subjects << @comment.structure.subjects
    end
    @user.save
    @user
  end
end
