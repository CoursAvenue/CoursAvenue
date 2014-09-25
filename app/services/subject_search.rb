class SubjectSearch

  # params: params
  #     name:          fulltext
  #     subject_id:    slug of a subject
  #     audience_ids:  [1, 2, 3]
  #     level_ids:     [1, 2, 3]
  def self.search params

    @search = Sunspot.search(Subject) do
      fulltext params[:name] if params[:name].present?
    end

    @search
  end

end
