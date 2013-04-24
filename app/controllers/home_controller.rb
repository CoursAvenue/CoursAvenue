# encoding: utf-8
class HomeController < ApplicationController
  def index
    # For search
    @audiences        = Audience.all
    @levels           = Level.all
    @promoted_courses = Course.where{is_promoted == true}.shuffle[0...3]
    @comments         = Comment.order('created_at DESC').limit(15)

    @homepage_images  = [['https://s3-eu-west-1.amazonaws.com/coursavenue/homepage_images/dance.jpg', 'Cours de danse'],
                         ['https://s3-eu-west-1.amazonaws.com/coursavenue/homepage_images/mime.jpg', 'Cours de théatre'],
                         ['https://s3-eu-west-1.amazonaws.com/coursavenue/homepage_images/painter.jpg', 'Cours de peinture']]

    fresh_when @comments.first, etag: [@comments.first, ENV["ETAG_VERSION_ID"]], public: true
    expires_in 1.minute, public: true
  end
end
