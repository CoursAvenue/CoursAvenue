class StructureSearch

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
        with(:location).in_radius(params[:lat], params[:lng], params[:radius] || 10, bbox: (params[:bbox] ? params[:bbox] : true)) if params[:lat].present? and params[:lng].present?
      end

      # --------------- Subjects
      if params[:subject_id].present?
        if params[:subject_id] == 'other'
          without(:subject_slugs, Subject.stars.map(&:slug))
        else
          with(:subject_slugs).any_of [params[:subject_id]]
        end
      end
      # For admin dashboard purpose
      with(:subject_ids).any_of params[:subject_ids]                                 if params[:subject_ids].present?

      with(:zip_codes).any_of params[:zip_codes]                                     if params[:zip_codes].present?

      ######################################################################
      # Other filters                                                      #
      ######################################################################
      with(:structure_type).any_of   params[:structure_types]                       if params[:structure_types].present?
      with(:funding_type_ids).any_of params[:funding_type_ids].map(&:to_i)          if params[:funding_type_ids].present?

      with :is_sleeping,  params[:is_sleeping]                                      if params.has_key? :is_sleeping
      with :has_admin,    params[:has_admin]                                        if params.has_key? :has_admin
      with :active, true

      with :has_logo,                params[:has_logo]                              if params[:has_logo].present?

      with(:nb_comments).greater_than params[:nb_comments].to_i                     if params[:nb_comments].present?

      if params[:sort] == 'premium'
        order_by :premium, :desc
      end
      order_by :search_score, :desc
      order_by :view_count, :asc
      order_by :has_admin, :desc

      paginate page: (params[:page].present? ? params[:page] : 1), per_page: (params[:per_page] || 15)
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

  def self.similar_profile structure, limit=4
    parent_subject = structure.subjects.at_depth(0).first
    @structures    = []
    if parent_subject
      @structures << StructureSearch.search({lat: structure.latitude,
                                            lng: structure.longitude,
                                            without_id: structure.id,
                                            radius: 10,
                                            sort: 'premium',
                                            nb_comments: 1,
                                            has_logo: true,
                                            per_page: limit,
                                            subject_id: parent_subject.slug
                                          }).results
      # If there is not enough with the same subjects
    end
    @structures = @structures.flatten.uniq
    if @structures.length < limit
      @structures << StructureSearch.search({lat: structure.latitude,
                                             lng: structure.longitude,
                                             without_id: structure.id,
                                             radius: 50,
                                             sort: 'premium',
                                             nb_comments: 1,
                                             has_logo: true,
                                             per_page: (limit - @structures.length)
                                          }).results
    end
    if @structures.length < limit
      @structures << StructureSearch.search({lat: structure.latitude,
                                             lng: structure.longitude,
                                             without_id: structure.id,
                                             radius: 500,
                                             sort: 'premium',
                                             has_logo: true,
                                             per_page: (limit - @structures.length)
                                          }).results
    end
    @structures = @structures.flatten.uniq
    return @structures[0..(limit - 1)]
  end
end
