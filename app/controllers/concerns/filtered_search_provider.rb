module FilteredSearchProvider extend ActiveSupport::Concern

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

  def params_has_planning_filters?
    (params.keys & PLANNING_FILTERED_KEYS).any?
  end

  def search_plannings
    search          = PlanningSearch.search(params, group: :structure_id_str)
    structures      = search.group(:structure_id_str).groups.collect do |planning_group|
      planning_group.results.first.structure
    end
    total           = search.group(:structure_id_str).total

    [ structures, total ]
  end

  def search_structures
    search           = StructureSearch.search(params)
    structures       = search.results
    total            = search.total

    [ structures, total ]
  end

  def retrieve_location
    StructureSearch.retrieve_location(params)
  end

  def jasonify(structures, options = {})
    # we splat the structures to ensure that a single
    # structure is treated as an array <3 Ruby
    
    [*structures].map do |structure|
      StructureSerializer.new(structure, options.merge({ root: false }))
    end
  end


end
