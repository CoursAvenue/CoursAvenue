# encoding: utf-8
class HomeController < ApplicationController
  def index
    # For search
    @audiences        = Audience.all
    @levels           = Level.all
    @promoted_courses = Course.where{is_promoted == true}.shuffle[0...3]
    @comments         = Comment.order('created_at DESC').limit(15)

    expires_in 1.day
    fresh_when last_modified: @comments.first.updated_at, public: true
  end
end
