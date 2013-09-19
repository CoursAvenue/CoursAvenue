# encoding: utf-8
class Pro::CommentsController < InheritedResources::Base
  before_filter :authenticate_pro_admin!
  load_and_authorize_resource :comment

  layout 'admin'

  def index
    @comments                        = Comment.accepted.order('created_at DESC').limit(40)
    @waiting_for_deletion_comments   = Comment.waiting_for_deletion.order('created_at DESC')
    @waiting_for_validation_comments = Comment.pending.order('created_at DESC')
  end
end
