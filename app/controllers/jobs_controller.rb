# encoding: utf-8
class JobsController < ApplicationController

  layout :get_layout

  # GET jobs/frontend-developpeur
  def frontend_developper
  end

  private

  def get_layout
    if action_name == 'index'
      'pages'
    else
      'empty_body_with_footer'
    end
  end
end
