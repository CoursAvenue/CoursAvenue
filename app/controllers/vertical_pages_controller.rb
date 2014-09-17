# encoding: utf-8
class VerticalPagesController < ApplicationController
  layout 'pages'
  before_action :load_cities

  def redirect_to_show
    @vertical_page = VerticalPage.find(params[:id])
    redirect_to vertical_page_path(@vertical_page.subject.root, @vertical_page), status: 301
  end

  def show_root
    @vertical_page = VerticalPage.find(params[:id])
    @subject       = @vertical_page.subject
    @ancestors     = @subject.ancestors
    render action: :show
  end

  def show
    @vertical_page = VerticalPage.find(params[:id])
    if @vertical_page.slug != params[:id]
      redirect_to vertical_page_path(@vertical_page.subject.root, @vertical_page), status: 301
    end
    @subject       = @vertical_page.subject
    @ancestors     = @subject.ancestors
  end

  def index
  end

  def load_cities
    paris     = City.find 'paris'
    marseille = City.find 'marseille'
    lyon      = City.find 'lyon'
    toulouse  = City.find 'toulouse'
    nice      = City.find 'nice'
    nantes    = City.find 'nantes'
    bordeaux  = City.find 'bordeaux'
    lille     = City.find 'lille'
    @cities = [paris, marseille, lyon, toulouse, nice, nantes, bordeaux, lille]
  end
end
