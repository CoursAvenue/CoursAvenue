class AdminSearch

  # params: params
  #     name:          fulltext
  #     subject_id:    slug of a subject
  def self.search params
    @search = Sunspot.search(Admin) do
      fulltext params[:name]           if params[:name].present?
      paginate page: (params[:page] || 1), per_page: (params[:per_page] || 15)

      with :super_admin, false

      if params[:sort] == 'comments_count_desc'
        order_by :comments_count, :desc
      elsif params[:sort] == 'not_confirmed'
        order_by :not_confirmed, :asc
        order_by :created_at, :desc
      else
        order_by :created_at, :desc
      end

    end
    @search
  end

end
