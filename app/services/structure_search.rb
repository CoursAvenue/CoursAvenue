class StructureSearch

  # params: params
  #     name:          fulltext
  #     subject_id:    slug of a subject
  #     audience_ids:  [1, 2, 3]
  #     level_ids:     [1, 2, 3]
  def self.search params
    params[:sort] ||= 'rating_desc'
    retrieve_location params

    format_bbox_params params

    # Encode name in UTF8 as it can be submitted by the user and can be bad
    params[:name] = params[:name].force_encoding("UTF-8") if params[:name].present?
    @search = Sunspot.search(Structure) do

      facet :subject_ids
      fulltext params[:name]                             if params[:name].present?

      # --------------- Geolocation
      if params[:bbox_sw] && params[:bbox_ne]
        with(:location).in_bounding_box(params[:bbox_sw], params[:bbox_ne])
      else
        with(:location).in_radius(params[:lat], params[:lng], params[:radius] || 7, bbox: (params.has_key?(:bbox) ? params[:bbox] : true)) if params[:lat].present? and params[:lng].present?
      end

      # --------------- Subjects
      if params[:subject_slugs].present?
        with(:subject_slugs).any_of  params[:subject_slugs]
      else
        with(:subject_slugs).any_of [params[:subject_id]]  if params[:subject_id].present?
      end


      # For the home screen link "Autres"
      if params[:exclude].present?
        without(:subject_slugs, params[:exclude])
      elsif params[:other].present?
        without(:subject_slugs, Subject.stars.map(&:slug))
      end

      ######################################################################
      # Other filters                                                      #
      ######################################################################
      with(:structure_type).any_of   params[:structure_types]                    if params[:structure_types].present?
      with(:funding_type_ids).any_of params[:funding_type_ids].map(&:to_i)       if params[:funding_type_ids].present?

      with :active,  true

      with :has_logo   ,  params[:has_logo]    if params[:has_logo].present?

      order_by :has_admin, :desc
      order_by :has_logo, :desc
      if params[:sort] == 'rating_desc'
        order_by :nb_comments, :desc
      elsif params[:sort] == 'relevancy'
        order_by :has_comment, :desc
      end
      paginate page: (params[:page] || 1), per_page: (params[:per_page] || 15)
    end

    @search
  end

  def self.retrieve_location params
    if params[:lat].blank? or params[:lng].blank?
      params[:lat] = 48.8592
      params[:lng] = 2.3417
    end

    [params[:lat], params[:lng]]
  end

  def self.format_bbox_params params
    params[:bbox_sw] = params[:bbox_sw].split(',') if params[:bbox_sw].is_a? String
    params[:bbox_ne] = params[:bbox_ne].split(',') if params[:bbox_ne].is_a? String
  end

  def self.similar_profile structure, limit=3
    parent_subject = structure.subjects.at_depth(0).first
    @structures    = []
    if parent_subject
      @structures << StructureSearch.search({lat: structure.latitude,
                                            lng: structure.longitude,
                                            radius: 10,
                                            sort: 'rating_desc',
                                            has_logo: true,
                                            per_page: 3,
                                            subject_id: parent_subject.slug
                                          }).results
      # If there is not enough with the same subjects
    end
    @structures = @structures.flatten
    if @structures.length < 3
      @structures << StructureSearch.search({lat: structure.latitude,
                                            lng: structure.longitude,
                                            radius: 500,
                                            sort: 'rating_desc',
                                            has_logo: true,
                                            per_page: (3 - @structures.length)
                                          }).results
    end
    @structures = @structures.flatten
    return @structures[0..(limit - 1)]
  end
end
