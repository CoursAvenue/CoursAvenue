# encoding: utf-8
class HomeController < ApplicationController

  def index
    # For search
    @audiences        = Audience.all
    @levels           = Level.all
    @comments         = Comment.accepted.order('created_at DESC').limit(4).offset(1)
    @last_comment     = Comment.accepted.last
  end
end
