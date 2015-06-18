module FilteredSearchProvider
  MAP_DEFAULT_ZOOM = 14
  extend ActiveSupport::Concern

  # When one of these keys are in the params, we need to search on Plannings instead of Structure
  PLANNING_FILTERED_KEYS = ['audience_ids', 'level_ids', 'min_age_for_kids', 'max_price', 'min_price',
                            'price_type', 'max_age_for_kids', 'trial_course_amount', 'course_types',
                            'week_days', 'discount_types', 'start_date', 'end_date', 'start_hour', 'end_hour']

  FILTERED_SEARCH_KEYS = PLANNING_FILTERED_KEYS + ['lat', 'lng', 'bbox_ne', 'bbox_sw', 'address_name', 'subject_id']

  # Keys that should be formatted as arrays
  ARRAY_KEYS = ['bbox_ne', 'bbox_sw', 'audience_ids', 'level_ids', 'course_types', 'week_days', 'discount_types']

  # if the subject_id is set, we return a subject
  # otherwise just nil
  def filter_by_subject?
    params.delete(:subject_id) if params[:subject_id].blank?

    if params[:subject_id].present? and params[:subject_id] != 'other'
      Subject.friendly.find params[:subject_id]
    else
      # Little hack to determine if the name is equal a subject
      _name = params[:name]
      if _name.present? and Subject.where( Subject.arel_table[:name].matches(_name) ).any?
        Subject.where( Subject.arel_table[:name].matches(_name) ).first
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

  # Return all parameters that are used for search
  #
  # @return Hash
  def get_filters_params
    params.select { |key, value| FILTERED_SEARCH_KEYS.include? key }
  end

  # Search for plannings regarding the params
  #
  # @return array [ structures models, places, total of results(meaning structures)]
  def search_plannings
    sanatize_params
    search       = PlanningSearch.search(params, group: :structure_id_str)
    place_search = PlanningSearch.search(params, group: :place_id_str)
    structures   = []
    places       = []
    place_search.group(:place_id_str).groups.each do |place_group|
      places << place_group.value
    end
    search.group(:structure_id_str).groups.each do |structure_group|
      structure = Structure.where(id: structure_group.value).first || Structure.where(slug: structure_group.value).first
      structures << structure
    end
    places                  = places.uniq
    total                   = search.group(:structure_id_str).total
    subject_slugs_with_more_than_five_results = search.facet(:subject_slugs).rows.select{ |row| row.count > 5 }.map(&:value)
    [ structures, places, total, subject_slugs_with_more_than_five_results ]
  end

  def search_structures
    sanatize_params
    search                  = StructureSearch.search(params)
    structures              = search.results
    total                   = search.total
    subject_slugs_with_more_than_five_results = search.facet(:subject_slugs).rows.select{ |row| row.count > 5 }.map(&:value)
    [ structures, total, subject_slugs_with_more_than_five_results ]
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
    options[:serializer] ||=StructureSerializer
    [*structures].map do |structure|
      options[:serializer].new(structure, { root: false }.merge(options))
    end
  end


  # To prevent bugs: turn hashes like { '0' => 'lala' } into arrays
  # Only done on certain params
  # Refered bug: https://bugsnag.com/coursavenue/coursavenue/errors/53259530318af3512e095ed3#request
  #
  # @return params
  def sanatize_params
    params[:page] = 1 if params[:page] and params[:page].to_i < 1
    params.keys.each do |key|
      if ARRAY_KEYS.include?(key) and params[key].is_a? Hash
        params[key] = params[key].values
      end
    end
    params
  end
end
