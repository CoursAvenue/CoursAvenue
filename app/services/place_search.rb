class PlaceSearch

  def self.search params
    @search = Sunspot.search(Place) do
      fulltext                     params[:name]         if params[:name].present?
      with(:subject_slugs).any_of [params[:subject_id]]  if params[:subject_id]

      with(:location).in_radius(params[:lat], params[:lng], params[:radius] || 10, :bbox => true) if params[:lat].present? and params[:lng].present?

      with :active,  true

      if params[:sort] == 'rating_desc'
        order_by :rating, :desc
        order_by :nb_comments, :desc
      else
        order_by :nb_courses, :desc
        order_by :has_comment, :desc
        order_by_geodist(:location, params[:lat], params[:lng])
      end
      paginate page: (params[:page] || 1), per_page: (params[:per_page] || 15)
    end
    @search.results
  end

end
