# encoding: utf-8
class HomeController < ApplicationController
  def index
    # For search
    @audiences        = Audience.all
    @levels           = Level.all
    @promoted_courses = Course.where{is_promoted == true}.shuffle[0...3]
    @comments         = Comment.order('created_at DESC').limit(15)

    fresh_when @comments.first, etag: @comments.first.created_at, public: true
    expires_in 1.minute, public: true
  end
end
