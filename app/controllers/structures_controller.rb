# encoding: utf-8
class StructuresController < ApplicationController
  include FilteredSearchProvider

  respond_to :json

  layout :choose_layout

  def show
    begin
      @structure = Structure.friendly.find params[:id]
    rescue ActiveRecord::RecordNotFound
      place = Place.find params[:id]
      redirect_to structure_path(place.structure), status: 301
      return
    end
    @city           = @structure.city
    @places         = @structure.places
    @courses        = @structure.courses.without_open_courses.active
    @teachers       = @structure.teachers
    @medias         = @structure.medias.videos_first
    @comments       = @structure.comments.accepted.reject(&:new_record?)
    @comment        = @structure.comments.build
  end

  def jpo
    get_stuff_for_popup
    @structure    = Structure.friendly.find params[:id]
    @open_courses = @structure.courses.open_courses
    @city         = @structure.city
    @places       = @structure.courses.open_courses.map(&:places).flatten.uniq
    @teachers     = @structure.teachers
    @medias       = @structure.medias.videos_first.reject { |media| media.type == 'Media::Image' and media.cover }
    @comments     = @structure.comments.accepted.reject(&:new_record?)
    @comment      = @structure.comments.build
    respond_to do |format|
      format.html
    end
  end

  def index
    @app_slug = "filtered-search"
    @subject = filter_by_subject?

    params[:page] = 1 unless request.xhr?

    if params_has_planning_filters?
      @structures, @places, @total = search_plannings
    else
      @structures, @total = search_structures
    end

    @latlng = retrieve_location

    if params[:name].present?
      # Log search terms
      SearchTermLog.create(name: params[:name]) unless cookies["search_term_logs_#{params[:name]}"].present?
      cookies["search_term_logs_#{params[:name]}"] = { value: params[:name], expires: 12.hours.from_now }
    end

    respond_to do |format|
      format.json do
        render json: @structures,
               root: 'structures',
               place_ids: @places,
               query: params,
               query_string: request.env['QUERY_STRING'],
               each_serializer: StructureSerializer,
               meta: { total: @total, location: @latlng }
      end
      format.html do
        @models = jasonify @structures, place_ids: @places, query: params, query_string: request.env['QUERY_STRING']
        cookies[:structure_search_path] = request.fullpath
      end
    end
  end

  private

  def choose_layout
    if action_name == 'index'
      'search'
    else
      'users'
    end
  end

  def get_stuff_for_popup
    unless current_user or current_pro_admin
      @open_courses_slugs = {
      'Cours de Danse GRATUITS' => ['zum-tropikal-journee-portes-ouvertes-aquazumba',
                                    'journee-portes-ouvertes-stage-de-danse-parents-enfants',
                                    'bolly-deewani-danse-bollywood-et-fitness-bollywood-journee-portes-ouvertes-cours-de-comedie-musicale-bollywood'],
      'Cours de Théâtre & Scène GRATUITS' => ['journee-portes-ouvertes-ateliers-theatre-pour-enfants',
                                              'association-teya-g-journee-portes-ouvertes-atelier-en-toute-liberte-chant-danse-jeu-d-acteur',
                                              'journee-portes-ouvertes-comedien-de-doublage'],
      'Cours de Yoga & Bien-être GRATUITS' => ['julie-lecureuil-sophrologie-soi-journee-portes-ouvertes-cours-de-sophro-relaxation-bulle-detente-serenite',
                                              'association-les-quatre-piliers-journee-portes-ouvertes-aterlier-de-qi-gong-tai-chi-et-stretching-postural',
                                              'journee-portes-ouvertes-atelier-bien-etre-coaching-developpement-personnel'],
      'Cours de Musique & Chant GRATUITS' => ['journee-portes-ouvertes-cours-de-chant-moderne-jazz-chansons-rock-etc',
                                              'belliard-productions-journee-portes-ouvertes-guitare-basse-batterie-et-chant',
                                              'journee-portes-ouvertes-initiation-a-la-musique-persane-et-decouverte-des-instruments-iraniens'],
      'Cours de Dessin, Peinture & Arts GRATUITS' => ['atelier-terre-d-es-sens-journee-portes-ouvertes-cours-de-ceramique-et-de-sculpture',
                                              'vertumne-journee-portes-ouvertes-demonstration-de-composition-d-un-bouquet-de-printemps',
                                              'journee-portes-ouvertes-demonstrations-de-peintures-et-patines-decoratives-sur-bois'],
      'Cours de Sports & Arts martiaux GRATUITS' => ['paris-18e-kobukan-journee-portes-ouvertes-baby-karate',
                                              'glace-roller-inline-de-paris-g-r-i-p-journee-portes-ouvertes-initiation-au-patinage-artistique-et-au-roller-en-ligne',
                                              'retraite-sportive-de-paris-journee-portes-ouvertes-gymnastique-senior'],
      'Cours de Cuisine & Vins GRATUITS' => ['super-naturelle-journee-portes-ouvertes-demonstration-et-degustation-de-makis-et-sushis-bio',
                                              'journee-portes-ouvertes-atelier-decouverte-decoration-de-cupcakes',
                                              'aux-papilles-de-bebe-journee-portes-ouvertes-cours-de-cuisine-adaptee-aux-bebes']
      }
    end
  end
end
