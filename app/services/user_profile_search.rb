class UserProfileSearch

  # params: params
  #     name:          fulltext
  #     subject_id:    slug of a subject
  def self.search params
    @search = Sunspot.search(UserProfile) do
      fulltext params[:name]                         if params[:name].present?
      with(:tag_names).any_of params[:tags]          if params[:tags].present?
      with(:id).any_of params[:ids]                  if params[:ids].present?

      with :structure_id, params[:structure_id].to_i if params[:structure_id]

      order_by(params[:sort].to_sym, params[:order].to_sym) if params[:sort] and params[:order]

      paginate page: (params[:page] || 1), per_page: (params[:per_page] || 30)
    end
    @search
  end
end
