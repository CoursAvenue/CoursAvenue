# encoding: utf-8
class PlanningSearch

  def self.search params, options= {}
    params[:sort] ||= 'rating_desc'
    # retrieve_location params

    # Encode name in UTF8 as it can be submitted by the user and can be bad
    params[:name].force_encoding("UTF-8") if params[:name].present?

    @search = Sunspot.search(Planning) do
      if options[:group].present?
        group options[:group]
      end
      if params[:name].present?
        fulltext params[:name]
      end

      facet :subject_ids

      # --------------- Geolocation
      if params.has_key?(:bbox_sw) && params.has_key?(:bbox_ne)
        with(:location).in_bounding_box(params[:bbox_sw], params[:bbox_ne])
      elsif params.has_key?(:lat) and params.has_key?(:lng)
        with(:location).in_radius(params[:lat], params[:lng], (params[:radius] || 10), bbox: (params.has_key?(:bbox) ? params[:bbox] : true))
      end

      all_of do
        # with :active_structure,  true
        with :active_course, true
        with :visible,                                    params[:visible]                              if params.has_key? :visible

        with(:start_hour).greater_than_or_equal_to        params[:start_hour].to_i                      if params.has_key? :start_hour
        with(:end_hour).less_than_or_equal_to             params[:end_hour].to_i                        if params.has_key? :end_hour

        with(:start_date).greater_than_or_equal_to        params[:start_date]                           if params.has_key? :start_date
        if params[:end_date].present?
          with(:end_date).less_than_or_equal_to           params[:end_date]
        else # Always retrieve future plannings
          with(:end_date).greater_than Date.today
        end

        with :structure_id,        params[:structure_id].to_i                                         if params.has_key? :structure_id

        with(:audience_ids).any_of params[:audience_ids]                                              if params.has_key? :audience_ids
        with(:level_ids).any_of    params[:level_ids]                                                 if params.has_key? :level_ids
        with(:week_days).any_of    params[:week_days].map(&:to_i)                                     if params.has_key? :week_days

        with(:max_age_for_kid).greater_than_or_equal_to   params[:min_age_for_kids].to_i              if params.has_key? :min_age_for_kids
        with(:min_age_for_kid).less_than_or_equal_to      params[:max_age_for_kids].to_i              if params.has_key? :max_age_for_kids

        ######################################################################
        # Subjects                                                           #
        ######################################################################
        # For the home screen link "Autres"
        if params[:subject_id].present?
          if params[:subject_id] == 'other'
            without(:subject_slugs, Subject.stars.map(&:slug))
          else
            with(:subject_slugs).any_of [params[:subject_id]]
          end
        end

        ######################################################################
        # Other filters                                                      #
        ######################################################################
        with(:course_type).any_of                          [params[:course_types]].flatten            if params.has_key? :course_types

        if params.has_key? :trial_course_amount
          with :has_trial_course,                          true
          with(:trial_course_amount).less_than_or_equal_to params[:trial_course_amount].to_i
        else
          with :has_trial_course,                          true                                       if params.has_key? :has_trial_course
        end

        ######################################################################
        # Prices                                                             #
        ######################################################################
        # --------------- Iterating over all types of prices
        if params.has_key? :price_type
          with(:price_types).any_of                                      [params[:price_type]]
          with("#{params[:price_type]}_min_price".to_sym).greater_than params[:min_price].to_i if params.has_key? :min_price
          with("#{params[:price_type]}_min_price".to_sym).less_than    params[:max_price].to_i if params.has_key? :max_price
        else
          with(:max_price).greater_than params[:min_price] if params.has_key? :min_price
          with(:min_price).less_than    params[:max_price] if params.has_key? :max_price
        end

        # --------------- Structure filters
        with(:discounts).any_of                            params[:discount_types]                      if params.has_key? :discount_types

        with(:funding_type_ids).any_of                     params[:funding_type_ids].map(&:to_i)        if params.has_key? :funding_type_ids

        with(:structure_type).any_of                       params[:structure_types]                     if params.has_key? :structure_types
      end

      order_by params[:order_by], (params[:order_direction] || :desc) if params.has_key? :order_by
      order_by :has_logo, :desc
      if params[:sort] == 'rating_desc'
        order_by :nb_comments, :desc
      elsif params[:sort] == 'relevancy'
        order_by :has_comment, :desc
      end

      paginate page: (params.has_key? :page ? params[:page] : 1), per_page: (params[:per_page] || 15)
    end

    @search
  end

  # def self.retrieve_location params
  #   if params[:lat].blank? or params[:lng].blank?
  #     params[:address_name] = 'Paris'
  #     params[:lat]          = 48.8592
  #     params[:lng]          = 2.3417
  #   end

  #   [params[:lat], params[:lng]]
  # end
end
