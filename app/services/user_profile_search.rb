class UserProfileSearch

  # params: params
  #     name:          fulltext
  #     subject_id:    slug of a subject
  def self.search params
    @search = Sunspot.search(UserProfile) do
      fulltext params[:name]                         if params[:name].present?
      order_by :first_name, :desc

      with :structure_id, params[:structure_id].to_i if params[:structure_id]

      paginate page: (params[:page] || 1), per_page: (params[:per_page] || 30)
    end
    @search
  end

end
