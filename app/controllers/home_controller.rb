# encoding: utf-8
class HomeController < ApplicationController

  layout 'admin_pages'

  def index
    # For search
    @audiences        = Audience.all
    @levels           = Level.all
    @comments         = Comment::Review.accepted.order('created_at DESC').limit(3).offset(1)
    @last_comment     = Comment::Review.accepted.last
  end
end
