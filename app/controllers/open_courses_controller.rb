# encoding: utf-8
class OpenCoursesController < ApplicationController
  include FilteredSearchProvider

  respond_to :json

  layout 'search'

  def index
    @app_slug = "open-doors-search"
    @subject  = filter_by_subject?

    unless current_user or current_pro_admin
      @open_courses = {
      'Cours de Danse GRATUITS' => ['zum-tropikal-journee-portes-ouvertes-aquazumba',
                                    'journee-portes-ouvertes-stage-de-danse-parents-enfants',
                                    'bolly-deewani-danse-bollywood-et-fitness-bollywood-journee-portes-ouvertes-cours-de-comedie-musicale-bollywood'],
      'Cours de Théâtre & Scène GRATUITS' => ['journee-portes-ouvertes-ateliers-theatre-pour-enfants',
                                              'association-teya-g-journee-portes-ouvertes-atelier-en-toute-liberte-chant-danse-jeu-d-acteur',
                                              'journee-portes-ouvertes-comedien-de-doublage'],
      'Cours de Yoga & Bien-être GRATUITS' => ['julie-lecureuil-sophrologie-soi-journee-portes-ouvertes-cours-de-sophro-relaxation-bulle-detente-serenite',
                                              'association-les-quatre-piliers-journee-portes-ouvertes-aterlier-de-qi-gong-tai-chi-et-stretching-postural',
                                              'portes-ouvertes-cours-loisirs/journee-portes-ouvertes-atelier-bien-etre-coaching-developpement-personnel'],
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
    params[:start_date]      ||= Date.parse('2014/04/05')
    params[:end_date]        ||= Date.parse('2014/04/06')
    params[:course_types]    ||= ["open_course"]
    params[:page]            ||= 1 unless request.xhr?
    params[:order_by]        ||= :jpo_score
    params[:order_direction] ||= :asc

    # Directly search plannings because it is by default filtered by dates
    @structures, @place_ids, @total = search_plannings

    @latlng = retrieve_location

    if params[:name].present?
      # Log search terms
      SearchTermLog.create(name: params[:name]) unless cookies["search_term_logs_#{params[:name]}"].present?
      cookies["search_term_logs_#{params[:name]}"] = {value: params[:name], expires: 12.hours.from_now}
    end

    respond_to do |format|
      format.json { render json: @structures,
                           root: 'structures',
                           jpo: true,
                           query: params,
                           query_string: request.env['QUERY_STRING'],
                           place_ids: @place_ids,
                           each_serializer: StructureSerializer,
                           meta: { total: @total, location: @latlng }}
      format.html do
        @models = jasonify @structures, jpo: true, place_ids: @place_ids, query: params, query_string: request.env['QUERY_STRING']
        cookies[:structure_search_path] = request.fullpath
      end
    end
  end

end
