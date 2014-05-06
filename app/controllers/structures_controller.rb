# encoding: utf-8
class StructuresController < ApplicationController
  include FilteredSearchProvider

  respond_to :json

  layout :choose_layout

  def show
    @structure = Structure.friendly.find params[:id]
    @structure_decorator = @structure.decorate

    # use the structure's plannings unless we would filter the plannings
    if params_has_filtered_search_filters?
      # For plannings search
      params[:structure_id] = @structure.id
      @planning_search = PlanningSearch.search(params)
      @plannings       = @planning_search.results
    else
      @plannings = @structure.plannings
    end

    # we need to group the plannings by course_id when we display them
    @planning_groups = {}
    @plannings.group_by(&:course_id).each do |course_id, plannings|
      @planning_groups[course_id] = plannings
    end
    @city      = @structure.city
    @place_ids = @plannings.map(&:place_id).uniq
    @medias    = @structure.medias.videos_first

    @model = StructureShowSerializer.new(@structure, {
      unlimited_comments: false,
      query:              get_filters_params,
      query_string:       request.env['QUERY_STRING'],
      planning_groups:    @planning_groups,
      place_ids:          @place_ids
    })
  end

  def jpo
    get_stuff_for_popup
    @structure    = Structure.friendly.find params[:id]
    @open_courses = @structure.courses.active.open_courses
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

    # We remove bbox parameters if user is on mobile since we don't show the map
    if mobile_device?
      params.delete :bbox_ne
      params.delete :bbox_sw
    end

    params[:page] = 1 unless request.xhr?

    if params_has_planning_filters?
      @structures, @places, @total = search_plannings
    else
      @structures, @total = search_structures
    end

    @latlng = retrieve_location
    @models = jasonify @structures

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

      # 'query' is the current query string, which allows us to direct users to
      # a filtered version of the structures show action
      format.html do
        @models = jasonify @structures, place_ids: @places, query: params, query_string: request.env['QUERY_STRING']
        cookies[:structure_search_path] = request.fullpath
      end
    end
  end

  def follow
    @structure = Structure.friendly.find params[:id]
    following = Followings.create( structure: @structure, user: current_user)
    respond_to do |format|
      format.html { redirect_to structure_path(@structure), notice: "Vous suivez désormais #{@structure.name}"}
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
    @open_courses_slugs = {
    ['Cours de Danse GRATUITS', 'danse'] => ['zum-tropikal-journee-portes-ouvertes-aquazumba',
                                  'journee-portes-ouvertes-stage-de-danse-parents-enfants',
                                  'bolly-deewani-danse-bollywood-et-fitness-bollywood-journee-portes-ouvertes-cours-de-comedie-musicale-bollywood'],
    ['Cours de Théâtre & Scène GRATUITS', 'theatre-scene'] => ['journee-portes-ouvertes-ateliers-theatre-pour-enfants',
                                            'association-teya-g-journee-portes-ouvertes-atelier-en-toute-liberte-chant-danse-jeu-d-acteur',
                                            'journee-portes-ouvertes-comedien-de-doublage'],
    ['Cours de Yoga & Bien-être GRATUITS', 'yoga-bien-etre-sante'] => ['julie-lecureuil-sophrologie-soi-journee-portes-ouvertes-cours-de-sophro-relaxation-bulle-detente-serenite',
                                            'association-les-quatre-piliers-journee-portes-ouvertes-aterlier-de-qi-gong-tai-chi-et-stretching-postural',
                                            'journee-portes-ouvertes-atelier-bien-etre-coaching-developpement-personnel'],
    ['Cours de Musique & Chant GRATUITS', 'musique-chant'] => ['journee-portes-ouvertes-cours-de-chant-moderne-jazz-chansons-rock-etc',
                                            'belliard-productions-journee-portes-ouvertes-guitare-basse-batterie-et-chant',
                                            'journee-portes-ouvertes-initiation-a-la-musique-persane-et-decouverte-des-instruments-iraniens'],
    ['Cours de Dessin, Peinture & Arts GRATUITS', 'dessin-peinture-arts-plastiques'] => ['atelier-terre-d-es-sens-journee-portes-ouvertes-cours-de-ceramique-et-de-sculpture',
                                            'vertumne-journee-portes-ouvertes-demonstration-de-composition-d-un-bouquet-de-printemps',
                                            'journee-portes-ouvertes-demonstrations-de-peintures-et-patines-decoratives-sur-bois'],
    ['Cours de Sports & Arts martiaux GRATUITS', 'sports-arts-martiaux'] => ['journee-portes-ouvertes-baby-karate',
                                            'glace-roller-inline-de-paris-g-r-i-p-journee-portes-ouvertes-initiation-au-patinage-artistique-et-au-roller-en-ligne',
                                            'retraite-sportive-de-paris-journee-portes-ouvertes-gymnastique-senior'],
    ['Cours de Cuisine & Vins GRATUITS', 'cuisine-vins'] => ['super-naturelle-journee-portes-ouvertes-demonstration-et-degustation-de-makis-et-sushis-bio',
                                            'journee-portes-ouvertes-atelier-decouverte-decoration-de-cupcakes',
                                            'aux-papilles-de-bebe-journee-portes-ouvertes-cours-de-cuisine-adaptee-aux-bebes']
    }
  end
end
