class CommentSearch

  # params: params
  #     text:          fulltext
  #     subject_id:    slug of a subject
  #     audience_ids:  [1, 2, 3]
  #     level_ids:     [1, 2, 3]
  def self.search params
    params[:sort] ||= 'rating_desc'
    retrieve_location params

    @search = Sunspot.search(Comment::Review) do
      fulltext params[:text] if params[:text].present?

      # --------------- Geolocation
      if params[:lat].present? and params[:lng].present?
        with(:location).in_radius(params[:lat], params[:lng], params[:radius] || 7, bbox: (params.has_key?(:bbox) ? params[:bbox] : true))
      end

      with :has_title , params[:has_title]             if params[:has_title]
      with :has_avatar, params[:has_avatar]            if params[:has_avatar]
      with :accepted, true
      with :certified, params[:has_avatar]             if params[:certified]

      # --------------- Subjects
      with :subject_slug, params[:subject_slug]        if params[:subject_slug]

      paginate page: (params[:page] || 1), per_page: (params[:per_page] || 15)
      order_by :certified, :asc
      order_by :has_avatar, :desc
      order_by :created_at, :desc
    end

    @search
  end

  def self.search_activerecord(params)
    retrieve_location(params)

    page     = params[:page] || 1
    per_page = params[:per_page] || 15
    radius   = params[:radius] || 7

    # Default query, the one that is always the same.
    comments = Comment::Review.where(status: 'accepted').
      order(certified: :asc, created_at: :desc)

    # Now we actually build the query with the params we have.
    if params[:text].present?
      comments = comments.basic_search(params[:text])
    end

    if params[:lat].present? and params[:lng].present?
      # For some reason, `Place.select(:id, :latitude, :longitude)` and `Place.[...].select(:id)`
      # don't work here, so we have to get the full Place object.
      place_ids = Place.near([params[:lat], params[:lng]], radius, units: :km).map(&:id)
      # We start by getting all of the structures associated with comments.
      # We then get all of the places of the structure and finally check if the place is in the
      # right location.
      comments = comments.
        joins('INNER JOIN structures ON comments.commentable_id = structures.id').
        where(comments: { commentable_type: 'Structure' }).
        joins('INNER JOIN places ON structures.id = places.structure_id').
        where('places.id in (?)', place_ids).
        group('comments.id')
    end

    if params[:has_title].present?
      comments = comments.where.not(title: nil)
    end

    if params[:has_avatar].present?
      comments = comments.includes(:user).joins(:user).where('users.avatar IS NOT NULL')
    end

    if params[:certified].present?
      comments = comments.where(certified: params[:certified])
    end

    if params[:subject_slug].present?
      comments = comments.includes(:subjects).joins(:subjects).
        where('comments_subjects_.subject_id = subjects.id AND subjects.slug = ?', params[:subject_slug])
    end
    # Finally, we paginate the results.
    comments.page(page).per(per_page)
  end

  def self.retrieve_location params
    if params[:lat].blank? or params[:lng].blank?
      params[:lat] = 48.8592
      params[:lng] = 2.3417
    end

    [params[:lat], params[:lng]]
  end
end
