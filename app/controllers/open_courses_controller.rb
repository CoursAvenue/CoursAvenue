# encoding: utf-8
class OpenCoursesController < ApplicationController
  include FilteredSearchProvider

  respond_to :json

  layout 'search'

  def index
    respond_to do |format|
      format.html { redirect_to structures_path, status: 301 }
    end
  end
end
