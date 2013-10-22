class StructureSearch

  # params: params
  #     name:          fulltext
  #     subject_id:    slug of a subject
  def self.search params
    params[:sort] ||= 'rating_desc'
    retrieve_location params
    @search = Sunspot.search(Structure) do
      fulltext params[:name]                             if params[:name].present?

      with(:subject_slugs).any_of [params[:subject_id]]  if params[:subject_id]

      # For the home screen link "Autres"
      if params[:exclude].present?
        without(:subject_slugs, params[:exclude])
      elsif params[:other].present?
        without(:subject_slugs, ['danse', 'musique-chant', 'theatre'])
      end

      if params[:bbox_sw] && params[:bbox_ne]
        with(:location).in_bounding_box(params[:bbox_sw], params[:bbox_ne])
      else
        with(:location).in_radius(params[:lat], params[:lng], params[:radius] || 7, bbox: (params.has_key?(:bbox) ? params[:bbox] : true)) if params[:lat].present? and params[:lng].present?
      end

      with :active,  true

      with :has_picture,  params[:has_picture] if params[:has_picture].present?
      with :has_logo   ,  params[:has_logo]    if params[:has_logo].present?

      order_by :has_admin, :desc
      order_by :has_logo, :desc
      if params[:sort] == 'rating_desc'
        order_by :nb_comments, :desc
      elsif params[:sort] == 'relevancy'
        order_by :has_comment, :desc
        # order_by_geodist(:location, params[:lat], params[:lng]) if params[:lat].present? and params[:lng].present?
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
end
