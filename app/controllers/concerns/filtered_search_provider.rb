module FilteredSearchProvider
  extend ActiveSupport::Concern

  PLANNING_FILTERED_KEYS = ['audience_ids', 'level_ids', 'min_age_for_kids', 'max_price', 'min_price',
                            'price_type', 'max_age_for_kids', 'trial_course_amount', 'course_types',
                            'week_days', 'discount_types', 'start_date', 'end_date', 'start_hour', 'end_hour']

  # if the subject_id is set, we return a subject
  # otherwise just nil
  def filter_by_subject?
    params.delete(:subject_id) if params[:subject_id].blank?
    if params[:subject_id] == 'other'
      params[:other] = true
      params.delete(:subject_id)
    end

    if params[:subject_id].present?
      Subject.friendly.find params[:subject_id]
    else
      # Little hack to determine if the name is equal a subject
      _name = params[:name]
      if _name.present? and Subject.where{name =~ _name}.any?
        Subject.where{name =~ _name}.first
      end
    end
  end

  # Tells if the search filters includes planning filters.
  # If it does, we will have to search through `Planning` and not `Structures`
  #
  # @return boolean
  def params_has_planning_filters?
    (params.keys & PLANNING_FILTERED_KEYS).any?
  end

  # Search for plannings regarding the params
  #
  # @return array [ structures models, total of results]
  def search_plannings
    search       = PlanningSearch.search(params, group: :structure_id_str)
    place_search = PlanningSearch.search(params, group: :place_id_str)
    structures   = []
    places       = []
    place_search.group(:place_id_str).groups.each do |place_group|
      places << place_group.results.first.try(:place_id)
    end
    search.group(:structure_id_str).groups.each do |planning_group|
      structures << planning_group.results.first.try(:structure)
    end
    places = places.uniq
    total  = search.group(:structure_id_str).total

    [ structures, places, total ]
  end

  def search_structures
    search           = StructureSearch.search(params)
    structures       = search.results
    total            = search.total

    [ structures, total ]
  end

  # Retrieve lat & lng of the current search
  #
  # @return Array [lat, lng]
  def retrieve_location
    StructureSearch.retrieve_location(params)
  end

  def jasonify(structures, options={})
    # we splat the structures to ensure that a single
    # structure is treated as an array <3 Ruby
    #
    [*structures].map do |structure|
      StructureSerializer.new(structure, { root: false }.merge(options))
    end
  end
end
