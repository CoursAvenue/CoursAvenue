class SubjectsController < ApplicationController
  include SubjectSeeker, FilteredSearchProvider
  layout 'pages'

  respond_to :json

  def search
    @subjects = Rails.cache.fetch "SubjectsController#search/#{params[:name]}" do
      SubjectSearch.search(name: params[:name]).results
    end
    respond_to do |format|
      format.json { render json: @subjects, each_serializer: SubjectSearchSerializer }
    end
  end

  def show
    @subject = Subject.fetch_by_id_or_slug params[:id]
    if @subject.vertical_pages.any?
      redirect_to vertical_page_path(@subject.root, @subject.vertical_pages.first), status: 301
    elsif @subject.parent and @subject.parent.vertical_pages.any?
      redirect_to vertical_page_path(@subject.root, @subject.parent.vertical_pages.first), status: 301
    elsif @subject.root.vertical_pages.any?
      redirect_to vertical_page_path(@subject.root, @subject.root.vertical_pages.first), status: 301
    else
      redirect_to root_path, status: 410
    end
  end

  def index
    @subjects = Subject.order('name ASC').all.map { |s| { name: s.name, slug: s.slug } }
    respond_to do |format|
      format.json { render json: @subjects.to_json }
    end
  end

  def descendants
    @descendants = get_descendants params
    respond_to do |format|
      if params[:callback]
        format.js { render json: { descendants: @descendants.to_json }, callback: params[:callback] }
      else
        format.json { render json: @descendants.to_json }
      end
    end
  end

  # GET subjects/list?token=26aa3c72ae6bab3e8762e8a5937b39e8
  def list
    if params[:token] != '26aa3c72ae6bab3e8762e8a5937b39e8'
      redirect_to root_path, status: 401
    end
  end
end
