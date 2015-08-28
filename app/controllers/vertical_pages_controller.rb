# encoding: utf-8
class VerticalPagesController < ApplicationController
  layout 'pages'

  before_action :load_cities

  before_action :load_root_vertical_page, only: [:show_root]
  before_action :load_vertical_page, only: [:show, :show_with_city, :show_with_neighborhood]

  def redirect_to_show
    @vertical_page = VerticalPage.friendly.find(params[:id])
    redirect_to vertical_page_path(@vertical_page.subject.root, @vertical_page), status: 301
  end

  def show_root
    @subject       = @vertical_page.subject
    @ancestors     = @subject.ancestors
    @vertical_page_decorator = @vertical_page.decorate
    render action: :show
  end

  def show
    @vertical_page_decorator = @vertical_page.decorate
    @subject                 = @vertical_page.subject
    if @subject.root?
      redirect_to root_vertical_page_path(@vertical_page), status: 301
    end
    @ancestors               = @subject.ancestors
  end

  def show_with_city
    @vertical_page_decorator = @vertical_page.decorate
    @subject                 = @vertical_page.subject
    @ancestors               = @subject.ancestors
    render action: :show
  end

  def show_with_neighborhood
    @vertical_page_decorator = @vertical_page.decorate
    @subject                 = @vertical_page.subject
    @ancestors               = @subject.ancestors
    @neighborhood            = City::Neighborhood.find(params[:neighborhood_id])
    render action: :show
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

  private

  def load_vertical_page
    @vertical_page = VerticalPage.friendly.find(params[:id])
    @city          = City.find(params[:city_id]) if params[:city_id]
    if @vertical_page.slug != params[:id]
      if @city
        redirect_to vertical_page_with_city_path(@vertical_page.subject.root, @vertical_page, @city), status: 301
      else
        redirect_to vertical_page_path(@vertical_page.subject.root, @vertical_page), status: 301
      end
    end
  end

  def load_root_vertical_page
    @vertical_page = VerticalPage.friendly.find(params[:id])
    if @vertical_page.slug != params[:id]
      redirect_to root_vertical_page_path(@vertical_page), status: 301
    end
  end
end
