class StructureSearch
  # params: params
  #     name:          fulltext
  #     subject_id:    slug of a subject
  #     audience_ids:  [1, 2, 3]
  #     level_ids:     [1, 2, 3]
  def self.search params
    params[:sort] ||= 'rating_desc'
    retrieve_location params

    week_day_hours = self.week_day_hours params
    course_dates   = self.course_dates params
    self.build_prices params
    @search        = Sunspot.search(Structure) do
      fulltext params[:name]                             if params[:name].present?

      # --------------- Geolocation
      if params[:bbox_sw] && params[:bbox_ne]
        with(:location).in_bounding_box(params[:bbox_sw], params[:bbox_ne])
      else
        with(:location).in_radius(params[:lat], params[:lng], params[:radius] || 7, bbox: (params.has_key?(:bbox) ? params[:bbox] : true)) if params[:lat].present? and params[:lng].present?
      end
      with(:subject_slugs).any_of [params[:subject_id]]  if params[:subject_id].present?

      # --------------- Subjects
      # For the home screen link "Autres"
      if params[:exclude].present?
        without(:subject_slugs, params[:exclude])
      elsif params[:other].present?
        without(:subject_slugs, Subject.stars.map(&:slug))
      end

      # --------------- Other filters
      with(:audience_ids).any_of           params[:audience_ids].map(&:to_i)       if params[:audience_ids].present?
      with(:level_ids).any_of              params[:level_ids].map(&:to_i)          if params[:level_ids].present?

      with(:course_type).any_of            params[:course_types]                   if params[:course_types].present?

      with :has_trial_course, true                                                 if params[:has_trial_course].present?

      with(:trial_course_amount).less_than params[:trial_course_amount]            if params[:trial_course_amount].present?

      with(:discounts).any_of              params[:discounts]                      if params[:discounts].present?
      with(:funding_type_ids).any_of       params[:funding_type_ids].map(&:to_i)   if params[:funding_type_ids].present?

      with :structure_type, params[:structure_type]                                if params[:funding_type_ids].present?

      with(:week_days).any_of              params[:week_days].map(&:to_i)          if params[:week_days].present?
      with(:week_day_hours).any_of         week_day_hours                          if week_day_hours

      # If it has a date ranges
      if course_dates
        with(:course_dates).any_of course_dates
      elsif params[:start_date]
        with(:end_date).greater_than Date.strptime(params[:start_date], '%d/%m/%Y')
      elsif params[:end_date]
        with(:start_date).less_than Date.strptime(params[:end_date], '%d/%m/%Y')
      end

      # --------------- Iterating over all types of prices
      %w(per_course book_ticket annual_subscription trimestrial_subscription).each do |name|
        with("#{name}_max_price".to_sym).greater_than params["#{name}_min_price".to_sym] if params["#{name}_min_price".to_sym].present?
        with("#{name}_min_price".to_sym).less_than    params["#{name}_max_price".to_sym] if params["#{name}_max_price".to_sym].present?
      end

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

  # Builds an array of hours from week_days, start_time and end_time
  def self.week_day_hours(params)
    return nil if params[:week_days].blank? and params[:start_time].blank? and params[:end_time].blank?
    # If blank, genreates for all week days regarding start and end time
    array_of_hours = []
    start_time     = params[:start_time].to_i || 0
    end_time       = params[:end_time].to_i   || 24
    week_days      = (params[:week_days].present? ? params[:week_days].map(&:to_i) : [0,1,2,3,4,5,6])
    week_days.each do |week_day|
      (start_time..end_time).to_a.each do |hour|
        array_of_hours << (week_day * 100) + hour
      end
    end
    return array_of_hours
  end

  # Create course date ranges
  def self.course_dates(params)
    return nil if params[:start_date].blank? or params[:end_date].blank?
    (Date.strptime(params[:start_date], '%d/%m/%Y')..Date.strptime(params[:end_date], '%d/%m/%Y')).to_a
  end

  def self.build_prices(params)
    if params[:price_type].present?
      params["#{params[:price_type]}_min_price"] = params[:min_price].to_i if params[:min_price].present?
      params["#{params[:price_type]}_max_price"] = params[:max_price].to_i if params[:max_price].present?
    end
  end
end
