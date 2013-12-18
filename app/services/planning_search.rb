# encoding: utf-8
class PlanningSearch

  def self.search params, options= {}
    params[:sort] ||= 'rating_desc'
    retrieve_location params

    @search = Sunspot.search(Planning) do
      group options[:group] if options[:group]

      fulltext params[:name] if params[:name].present?

      all_of do

        with :active_course, true

        with(:start_hour).greater_than_or_equal_to        params[:start_hour].to_i                      if params[:start_hour].present?
        with(:end_hour).less_than_or_equal_to             params[:end_hour].to_i                        if params[:end_hour].present?

        with(:start_date).greater_than_or_equal_to        params[:start_date].to_i                      if params[:start_date].present?
        if params[:end_date].present?
          with(:end_date).less_than_or_equal_to           params[:end_date].to_i
        else # Always retrieve future plannings
          with(:end_date).greater_than Date.today
        end

        with :structure_id,                   params[:structure_id].to_i                              if params[:structure_id]
        # --------------- Geolocation
        if params[:bbox_sw] && params[:bbox_ne]
          with(:location).in_bounding_box(params[:bbox_sw], params[:bbox_ne])
        elsif params[:lat].present? and params[:lng].present?
          with(:location).in_radius(params[:lat], params[:lng], (params[:radius] || 7))
        end

        with(:audience_ids).any_of params[:audience_ids]                                              if params[:audience_ids].present?
        with(:level_ids).any_of    params[:level_ids]                                                 if params[:level_ids].present?
        with(:week_days).any_of    params[:week_days].map(&:to_i)                                     if params[:week_days].present?

        # --------------- Subjects
        # For the home screen link "Autres"
        if params[:exclude].present?
          without(:subject_slugs, params[:exclude])
        elsif params[:other].present?
          without(:subject_slugs, Subject.stars.map(&:slug))
        end

        # --------------- Other filters
        with(:course_type).any_of                          params[:course_types]                      if params[:course_types].present?

        if params[:trial_course_amount].present?
          with :has_trial_course,                          true
          with(:trial_course_amount).less_than_or_equal_to params[:trial_course_amount].to_i
        else
          with :has_trial_course,                          true                                       if params[:has_trial_course].present?
        end

        # --------------- Iterating over all types of prices
        if params[:price_type].present?
          with(:price_types).any_of                                      [params[:price_type]]
          with("#{params[:price_type]}_min_price".to_sym).greater_than params[:min_price].to_i if params[:min_price].present?
          with("#{params[:price_type]}_min_price".to_sym).less_than    params[:max_price].to_i if params[:max_price].present?
        else
          with(:max_price).greater_than params[:min_price] if params[:min_price].present?
          with(:min_price).less_than    params[:max_price] if params[:max_price].present?
        end

        # --------------- Structure filters
        with(:discounts).any_of                            params[:discount_types]                      if params[:discount_types].present?

        with(:funding_type_ids).any_of                     params[:funding_type_ids].map(&:to_i)        if params[:funding_type_ids].present?

        with(:structure_type).any_of                       params[:structure_types]                     if params[:structure_types].present?
      end


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
      params[:name] = 'Paris'
      params[:lat]  = 48.8592
      params[:lng]  = 2.3417
    end

    [params[:lat], params[:lng]]
  end

end
