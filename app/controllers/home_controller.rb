# encoding: utf-8
class HomeController < ApplicationController

  layout :get_layout

  def redirect_to_account
    if current_user
      redirect_to dashboard_user_path(current_user)
    else
      redirect_to root_path(anchor: 'connexion')
    end
  end

  def index
    @comments         = Comment::Review.accepted.order('created_at DESC').limit(3).offset(1)
    @last_comment     = Comment::Review.accepted.last
  end

  def discovery_pass
    if current_user
      redirect_to user_discovery_passes_path(current_user)
    end
  end

  private

  def get_layout
    if action_name == 'pass_decouverte'
      'empty'
    else
      'pages'
    end
  end

  def layout_locals
    locals = { }
    locals[:hide_top_menu_search] = true if action_name == 'discovery_pass' or action_name == 'index'
    locals
  end
end
