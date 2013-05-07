# encoding: utf-8
class Pro::CommentsController < InheritedResources::Base
  before_filter :authenticate_pro_admin!

  layout 'admin'

  def index
    @comments = Comment.order('created_at DESC').limit(40)
  end
end
