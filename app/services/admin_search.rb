class AdminSearch

  # params: params
  #     name:          fulltext
  #     subject_id:    slug of a subject
  def self.search params
    @search = Sunspot.search(Admin) do
      fulltext params[:name]           if params[:name].present?
      paginate page: (params[:page] || 1), per_page: (params[:per_page] || 15)
    end
    @search
  end

end
