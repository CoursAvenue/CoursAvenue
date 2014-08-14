class UserSearch

  # params: params
  #     name:          fulltext
  #     subject_id:    slug of a subject
  def self.search params
    @search = Sunspot.search(User) do
      fulltext params[:name]                         if params[:name].present?

      with(:subject_ids).any_of params[:subject_ids] if params[:subject_ids].present?

      order_by :created_at, :desc
      paginate page: (params[:page] || 1), per_page: (params[:per_page] || 30)
    end
    @search
  end
end
