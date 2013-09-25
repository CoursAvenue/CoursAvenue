class SubjectsController < ApplicationController
  respond_to :json

  def index
    @subjects = Subject.order('name ASC').all.map{|s| {name: s.name, slug: s.slug} }
    respond_to do |format|
      format.json { render json: @subjects.to_json }
    end
  end

  def tree
    @subjects = {}
    Subject.roots.each do |root|
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
end
