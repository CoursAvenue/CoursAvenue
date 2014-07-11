class CommentSearch

  # params: params
  #     name:          fulltext
  #     subject_id:    slug of a subject
  #     audience_ids:  [1, 2, 3]
  #     level_ids:     [1, 2, 3]
  def self.search params
    params[:sort] ||= 'rating_desc'
    retrieve_location params

    @search = Sunspot.search(Comment::Review) do
      # --------------- Geolocation
      if params[:lat].present? and params[:lng].present?
        with(:location).in_radius(params[:lat], params[:lng], params[:radius] || 7, bbox: (params.has_key?(:bbox) ? params[:bbox] : true))
      end

      with :has_title, params[:has_title]              if params[:has_title]
      with :has_avatar, params[:has_avatar]            if params[:has_avatar]

      # --------------- Subjects
      if params[:subject_slugs].present?
        with(:subject_slugs).any_of  params[:subject_slugs]
      else
        with(:subject_slugs).any_of [params[:subject_id]]  if params[:subject_id].present?
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
