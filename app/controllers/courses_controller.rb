# encoding: utf-8
class CoursesController < ApplicationController

  def index
    redirect_to structures_path, status: 301
  end

end
