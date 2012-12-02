class HomeController < ApplicationController
  def index
    # For search
    @audiences = Audience.all
    @levels    = Level.all
  end
end
