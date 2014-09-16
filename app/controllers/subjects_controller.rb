class SubjectsController < ApplicationController
  include SubjectSeeker, FilteredSearchProvider
  layout 'pages'

  respond_to :json

  def show
    @subject = Subject.find params[:id]
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

  def tree
    if params[:parent]
      subject_roots = [Subject.friendly.find(params[:parent])]
    else
      subject_roots = Subject.roots
    end
    @subjects = {}
    subject_roots.each do |root|
      @subjects[root.name] = {}
      root.children.each do |sub_root|
        @subjects[root.name][sub_root.name] = []
        sub_root.children.each do |sub_sub_root|
          @subjects[root.name][sub_root.name] << sub_sub_root.name
        end
      end
    end
    respond_to do |format|
      format.json { render json: @subjects.to_json }
    end
  end

  def tree_2
    if params[:parent]
      subject_roots = [Subject.friendly.find(params[:parent])]
    else
      subject_roots = Subject.roots
    end
    @subjects = {}
    subject_roots.each do |root|
      @subjects["#{root.name} - #{root.slug} (#{root.courses.count})"] = {}
      root.children.each do |sub_root|
        @subjects["#{root.name} - #{root.slug} (#{root.courses.count})"]["#{sub_root.name} - #{sub_root.slug} (#{sub_root.courses.count})"] = []
        sub_root.children.each do |sub_sub_root|
          @subjects["#{root.name} - #{root.slug} (#{root.courses.count})"]["#{sub_root.name} - #{sub_root.slug} (#{sub_root.courses.count})"] << "#{sub_sub_root.name} - #{sub_sub_root.slug} (#{sub_sub_root.courses.count})"
        end
      end
    end
    respond_to do |format|
      format.json { render json: @subjects.to_json }
    end
  end

  # Returns all direct children and children at depth 2
  # GET on member
  def depth_2
    if params[:id] == 'other'
      @subjects   = Subject.roots_not_stars
      return_json = ActiveModel::ArraySerializer.new(@subjects, each_serializer: SubjectSerializer)
    else
      @subject = Subject.friendly.find params[:id]
      return_json = SubjectSerializer.new(@subject)
    end
    respond_to do |format|
      format.json { render json: return_json }
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
end
