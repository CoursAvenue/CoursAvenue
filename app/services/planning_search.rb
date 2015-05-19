# encoding: utf-8
class PlanningSearch
  ROOT_SUBJECT_ID_SUPPORTED = %w(danse theatre-scene yoga-bien-etre-sante musique-chant deco-mode-bricolage dessin-peinture-arts-plastiques sports-arts-martiaux cuisine-vins photo-video other)
  def self.search params, options= {}
    params[:sort] ||= 'rating-desc'
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

      facet :subject_ids, :subject_slugs

      # --------------- Geolocation
      if params[:bbox_sw].present? && params[:bbox_ne].present?
        with(:location).in_bounding_box(params[:bbox_sw], params[:bbox_ne])
      elsif params[:lat].present? and params[:lng].present?
        with(:location).in_radius(params[:lat], params[:lng], (params[:radius] || 10), bbox: (params[:bbox] ? params[:bbox] : true))
      end

      all_of do
        with :is_open_for_trial,                          true                                          if params[:is_open_for_trial].present?
        with :visible,                                    params[:visible]                              if params[:visible].present?
        with :is_published,                               params[:is_published]                         if params[:is_published].present?

        with(:start_hour).greater_than_or_equal_to        params[:start_hour].to_i                      if params[:start_hour].present?
        with(:end_hour).less_than_or_equal_to             params[:end_hour].to_i                        if params[:end_hour].present?

        with(:start_date).greater_than_or_equal_to        params[:start_date]                           if params[:start_date].present?
        if params[:end_date].present?
          with(:end_date).less_than_or_equal_to           params[:end_date]
        else # Always retrieve future plannings
          with(:end_date).greater_than_or_equal_to Date.today
        end

        with :structure_id,        params[:structure_id].to_i                                         if params[:structure_id].present?

        with(:audience_ids).any_of params[:audience_ids]                                              if params[:audience_ids].present?
        with(:level_ids).any_of    params[:level_ids]                                                 if params[:level_ids].present?
        with(:week_days).any_of    params[:week_days].map(&:to_i).uniq                                if params[:week_days].present?

        with(:max_age_for_kid).greater_than_or_equal_to   params[:min_age_for_kids].to_i              if params[:min_age_for_kids].present?
        with(:min_age_for_kid).less_than_or_equal_to      params[:max_age_for_kids].to_i              if params[:max_age_for_kids].present?

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
        with(:course_type).any_of                          [params[:course_types]].flatten            if params[:course_types]

        if params[:trial_course_amount].present?
          with :has_trial_course,                          true
          with(:trial_course_amount).less_than_or_equal_to params[:trial_course_amount].to_i
        else
          with :has_trial_course,                          true                                       if params[:has_trial_course]
        end

        ######################################################################
        # Prices                                                             #
        ######################################################################
        if params[:price_type] == 'first_course'
          with(:first_course_min_price).greater_than params[:min_price].to_i if params[:min_price].present?
          with(:first_course_min_price).less_than    params[:max_price].to_i if params[:max_price].present?
        elsif params[:price_type] == 'training'
          with(:training_min_price).greater_than params[:min_price].to_i if params[:min_price].present?
          with(:training_min_price).less_than    params[:max_price].to_i if params[:max_price].present?
        end

        # --------------- Structure filters
        with(:discounts).any_of                            params[:discount_types]                      if params[:discount_types].present?

        with(:funding_type_ids).any_of                     params[:funding_type_ids].map(&:to_i)        if params[:funding_type_ids].present?

        with(:structure_type).any_of                       params[:structure_types]                     if params[:structure_types].present?
      end

      if params[:order_by] == :start_date
        order_by :start_date, :asc
      else
        order_by :has_logo, :desc
        order_by :search_score, :desc
      end

      paginate page: (params[:page] ? params[:page] : 1), per_page: (params[:per_page] || 15)
    end

    @search
  end
end
