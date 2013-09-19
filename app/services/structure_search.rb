class StructureSearch

  def self.search params
    params[:sort] ||= 'rating_desc'
    retrieve_location params
    @search = Sunspot.search(Structure) do
      fulltext params[:name]                             if params[:name].present?
      with(:subject_slugs).any_of [params[:subject_id]]  if params[:subject_id]

      with(:location).in_radius(params[:lat], params[:lng], params[:radius] || 5, bbox: false) if params[:lat].present? and params[:lng].present?

      with :active,  true

      with :has_picture,  params[:has_picture] if params[:has_picture].present?
      with :has_logo   ,  params[:has_logo] if params[:has_logo].present?

      order_by :has_admin, :desc
      order_by :has_logo, :desc
      if params[:sort] == 'rating_desc'
        order_by :nb_comments, :desc
        order_by :rating, :desc
      elsif params[:sort] == 'relevancy'
        order_by :has_comment, :desc
        # order_by_geodist(:location, params[:lat], params[:lng]) if params[:lat].present? and params[:lng].present?
      end
      paginate page: (params[:page] || 1), per_page: (params[:per_page] || 15)
    end
    @search.results
  end

  def self.retrieve_location params
    if params[:lat].blank? or params[:lng].blank?
      params[:lat] = 48.8592
      params[:lng] = 2.3417
    end
  end
end
