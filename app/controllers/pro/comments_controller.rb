# encoding: utf-8
class Pro::CommentsController < InheritedResources::Base#Pro::ProController
  layout 'admin'

  def index
    @comments = Comment.order('created_at DESC').limit(40)
  end
end
