# encoding: utf-8
class CourseSearch
  def self.search params
    params[:sort] ||= 'rating_desc'
    retrieve_location params
    # params[:start_date] = I18n.l(Date.today) if params[:start_date].blank?
    @search = Sunspot.search(Course) do
      fulltext                              params[:name]                                           if params[:name].present?
      keywords                              [ params[:search_term] ]                                if params[:search_term].present?

      facet :has_free_trial_lesson

      with(:location).in_radius(params[:lat], params[:lng], params[:radius] || 7, bbox: true)
      with(:zip_codes).any_of                 params[:zip_codes]                                    if params[:zip_codes].present?
      # --------------- Subjects
      if params[:subject_slugs].present?
        with(:subject_slugs).any_of           params[:subject_slugs]
      else
        with(:subject_slugs).any_of           [params[:subject_id]]                                 if params[:subject_id]
      end

      with :available_in_discovery_pass,    true                                                    if params[:discovery_pass].present?
      with :has_description,                params[:has_description]                                if params[:has_description]
      with :structure_id,                   params[:structure_id].to_i                              if params[:structure_id]
      with(:type).any_of                    params[:types]                                          if params[:types].present?
      with(:audience_ids).any_of            params[:audiences]                                      if params[:audiences].present?
      with(:level_ids).any_of               params[:levels]                                         if params[:levels].present?
      with :week_days,                      params[:week_days]                                      if params[:week_days].present?

      with(:min_age_for_kid).less_than      params[:age][:max]                                      if params[:age].present? and params[:age][:max].present?
      with(:max_age_for_kid).greater_than   params[:age][:min]                                      if params[:age].present? and params[:age][:min].present?

      with(:end_date).greater_than          params[:start_date]                                     if params[:start_date].present?
      with(:start_date).less_than           params[:end_date]                                       if params[:end_date].present?

      with(:start_time).greater_than        TimeParser.parse_time_string(params[:time_range][:min]) if params[:time_range].present? and params[:time_range][:min].present?
      with(:end_time).less_than             TimeParser.parse_time_string(params[:time_range][:max]) if params[:time_range].present? and params[:time_range][:max].present?

      with(:time_slots).any_of              params[:time_slots]                                     if params[:time_slots].present?

      with :has_free_trial_lesson, params[:has_free_trial_lesson]                                   if params.has_key? :has_free_trial_lesson

      with(:approximate_price_per_course).greater_than         params[:price_range][:min].to_i      if params[:price_range].present? and params[:price_range][:min].present?
      with(:approximate_price_per_course).less_than            params[:price_range][:max].to_i      if params[:price_range].present? and params[:price_range][:max].present?

      with :active, true

      paginate page: (params[:page] || 1), per_page: (params[:per_page] || 15)
    end

    @search
  end

  def self.retrieve_location params
    if params[:lat].blank? or params[:lng].blank?
      params[:lat] = 48.8592
      params[:lng] = 2.3417
    end
  end
end
