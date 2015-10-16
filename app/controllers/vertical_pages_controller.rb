# encoding: utf-8
class VerticalPagesController < ApplicationController
  layout 'pages'

  before_action :load_cities

  before_action :load_root_vertical_page, only: [:show_root]
  before_action :load_vertical_page, only: [:show, :show_with_neighborhood]

  SUBJECT_1_DESCENDANTS = {
    'danse'                           => %w(danse-orientale danse-contemporaine danse-jazz tango-argentin danse-hip-hop-et-de-break-dance),
    'dessin-peinture-arts-plastiques' => %w(peinture decouverte-du-dessin-et-de-la-peinture croquis modelage dessin-au-crayon),
    'theatre-scene'                   => %w(theatre-amateur improvisation art-dramatique mise-en-scene comedie),
    'yoga-bien-etre-sante'            => %w(hatha-yoga relaxation respiration qi-gong)
  }
  def redirect_to_show
    @vertical_page = VerticalPage.friendly.find(params[:id])
    redirect_to vertical_page_path(@vertical_page.subject.root, @vertical_page), status: 301
  end

  def show_root
    @subject       = @vertical_page.subject
    @ancestors     = @subject.ancestors
    @vertical_page_decorator = @vertical_page.decorate

    @descendants = SUBJECT_1_DESCENDANTS[@subject.slug].map{|slug| VerticalPage.find(slug)} if SUBJECT_1_DESCENDANTS[@subject.slug]
    @test_landing = true
    if current_pro_admin
      render action: :show
    else
      render 'test_landing'
    end
  end

  def show
    @vertical_page_decorator = @vertical_page.decorate
    @subject                 = @vertical_page.subject
    @ancestors               = @subject.ancestors
    @test_landing = true
    if !current_pro_admin
      render 'test_landing'
    end
  end

  def show_with_neighborhood
    if params[:neighborhood_id] == 'undefined'
      redirect_to vertical_page_path(@vertical_page.subject.root, @vertical_page)
      return
    end
    @vertical_page_decorator = @vertical_page.decorate
    @subject                 = @vertical_page.subject
    @ancestors               = @subject.ancestors
    @neighborhood = City::Neighborhood.find(params[:neighborhood_id])
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
    if params[:city_id] and params[:city_id] != 'undefined'
      @city = City.find(params[:city_id])
    end

    if @vertical_page.slug != params[:id] or params[:city_id] == 'undefined'
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
