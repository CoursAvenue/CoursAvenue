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
    @vertical_page_decorator = @vertical_page.decorate
    render action: :show
  end

  def show
    @total_comments = Comment::Review.count
    @total_medias   = Media.count
    @vertical_page  = VerticalPage.find(params[:id])
    if @vertical_page.slug != params[:id]
      redirect_to vertical_page_path(@vertical_page.subject.root, @vertical_page), status: 301
    end
    @vertical_page_decorator = @vertical_page.decorate
    @subject                 = @vertical_page.subject
    if @subject.root?
      redirect_to root_vertical_page_path(@vertical_page), status: 301
    end
    @ancestors               = @subject.ancestors
  end

  def show_with_city
    @total_comments = Comment::Review.count
    @total_medias   = Media.count
    @city           = City.find(params[:city_id])
    @vertical_page  = VerticalPage.find(params[:id])
    if @vertical_page.slug != params[:id]
      redirect_to vertical_page_path(@vertical_page.subject.root, @vertical_page), status: 301
    end
    @vertical_page_decorator = @vertical_page.decorate
    @subject                 = @vertical_page.subject
    @ancestors               = @subject.ancestors
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
