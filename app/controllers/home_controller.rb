# encoding: utf-8
class HomeController < ApplicationController
  def index
    # For search
    @audiences        = Audience.all
    @levels           = Level.all
    @promoted_courses = Course.where{is_promoted == true}.shuffle[0...3]
    @city             = City.find('paris')
  end
end
