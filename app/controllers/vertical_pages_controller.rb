# encoding: utf-8
class VerticalPagesController < ApplicationController
  layout 'pages'
  before_action :load_cities

  def show
    @vertical_page = VerticalPage.find(params[:id])
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
