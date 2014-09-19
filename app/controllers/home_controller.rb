# encoding: utf-8
class HomeController < ApplicationController

  layout :get_layout

  def index
    # For search
    @audiences        = Audience.all
    @levels           = Level.all
    @comments         = Comment::Review.accepted.order('created_at DESC').limit(3).offset(1)
    @last_comment     = Comment::Review.accepted.last
  end

  def pass_loisirs
  end

  private

  def get_layout
    if action_name == 'pass_loisirs'
      'empty'
    else
      'pages'
    end
  end
end
