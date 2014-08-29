class StructureSearch
  extend StructuresHelper
  # params: params
  #     name:          fulltext
  #     subject_id:    slug of a subject
  #     audience_ids:  [1, 2, 3]
  #     level_ids:     [1, 2, 3]
  def self.search params={}
    params[:sort] ||= 'rating_desc'
    retrieve_location params

    format_bbox_params params

    # Encode name in UTF8 as it can be submitted by the user and can be bad
    params[:name] = params[:name].force_encoding("UTF-8") if params[:name].present?
    @search = Sunspot.search(Structure) do

      facet :subject_ids
      fulltext params[:name]                                                           if params[:name].present?

      without :id, params[:without_id]                                                 if params[:without_id].present?

      with(:email_status).any_of params[:email_status]                                 if params[:email_status].present?
      # --------------- Geolocation
      if params[:bbox_sw].present? && params[:bbox_ne].present? && params[:bbox_sw].length == 2 && params[:bbox_ne].length == 2
        with(:location).in_bounding_box(params[:bbox_sw], params[:bbox_ne])
      else
        with(:location).in_radius(params[:lat], params[:lng], (params[:radius].to_i > 0 ? params[:radius].to_i : 10), bbox: (params[:bbox] ? params[:bbox] : true)) if params[:lat].present? and params[:lng].present?
      end

      # --------------- Subjects
      if params[:subject_id].present?
        if params[:subject_id] == 'other'
          without(:subject_slugs, Subject.stars.map(&:slug))
        else
          with(:subject_slugs).any_of [params[:subject_id]].flatten # Flatten in case of subject_id is an array
        end
      end
      with(:nb_courses).greater_than_or_equal_to params[:nb_courses].to_i            if params[:nb_courses].present?
      with(:medias_count).greater_than_or_equal_to params[:medias_count].to_i        if params[:medias_count].present?
      # For admin dashboard purpose
      with(:subject_ids).any_of params[:subject_ids]                                 if params[:subject_ids].present?

      with(:zip_codes).any_of params[:zip_codes]                                     if params[:zip_codes].present?

      ######################################################################
      # Other filters                                                      #
      ######################################################################
      with(:structure_type).any_of   params[:structure_types]                       if params[:structure_types].present?
      with(:funding_type_ids).any_of params[:funding_type_ids].map(&:to_i)          if params[:funding_type_ids].present?

      with :is_sleeping,  params[:is_sleeping]                                      if params.has_key? :is_sleeping
      with :sleeping_email_opt_in,  params[:sleeping_email_opt_in]                  if params.has_key? :sleeping_email_opt_in
      with :has_admin,    params[:has_admin]                                        if params.has_key? :has_admin
      with :active, true

      with :has_logo,                params[:has_logo]                              if params[:has_logo].present?

      with(:nb_comments).greater_than params[:nb_comments].to_i                     if params[:nb_comments].present?

      if params[:sort] == 'premium'
        order_by :premium, :desc
      end
      if params[:root_subject_id].present?
        order_by "search_score_#{params[:root_subject_id]}".underscore.to_sym, :desc
      else
        order_by :search_score, :desc
      end
      order_by :view_count, :asc
      order_by :has_admin, :desc

      paginate page: (params[:page].present? ? params[:page] : 1), per_page: (params[:per_page] || 18)
    end

    @search
  end

  def self.retrieve_location params
    if (params[:lat].blank? or params[:lng].blank?) and params[:zip_codes].blank?
      params[:lat] = 48.8592
      params[:lng] = 2.3417
    end

    [params[:lat], params[:lng]]
  end

  def self.format_bbox_params params
    params[:bbox_sw] = params[:bbox_sw].split(',') if params[:bbox_sw].is_a? String
    params[:bbox_ne] = params[:bbox_ne].split(',') if params[:bbox_ne].is_a? String
  end

  def self.similar_profile structure, limit=4, _params={}
    # Choose parent subjects that are used if the profile has courses
    used_root_subjects = []
    if structure.is_sleeping?
      structure.initialize_sleeping_attributes
      used_root_subjects = root_subjects_from_string(structure).uniq
    elsif structure.courses.any?
      used_root_subjects = structure.courses.map(&:subjects).flatten.map(&:root).uniq
    else
      used_root_subjects = structure.subjects.at_depth(0).uniq
    end

    @structures = [] # The structures we will return at the ed
    7.times do |index|
      @structures << StructureSearch.search({lat: structure.latitude,
                                            lng: structure.longitude,
                                            without_id: structure.id,
                                            # Radius will increment from 2.7 to > 1000
                                            radius: Math.exp(index),
                                            sort: 'premium',
                                            has_logo: true,
                                            per_page: limit,
                                            subject_id: (used_root_subjects.any? ? used_root_subjects.map(&:slug) : nil)
                                          }.merge(_params)).results
      @structures = @structures.flatten.uniq
      break if @structures.length >= limit
    end
    @structures = @structures.sort{ |a, b| (a.search_score.present? ? a.search_score.to_i : 0) <=> (b.search_score.present? ? b.search_score.to_i : 0) }.reverse
    return @structures[0..(limit - 1)]
  end
end
