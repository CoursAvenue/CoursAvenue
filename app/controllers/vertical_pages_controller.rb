# encoding: utf-8
class VerticalPagesController < ApplicationController
  layout 'pages'

  def show
    @vertical_page = VerticalPage.find(params[:id])
    @subject       = @vertical_page.subject
  end

  def index
  end
end
