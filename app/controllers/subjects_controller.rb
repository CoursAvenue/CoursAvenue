class SubjectsController < ApplicationController
  respond_to :json

  def index
    @subjects = Subject.order('name ASC').all.map{|s| {name: s.name, slug: s.slug} }
    respond_to do |format|
      format.json { render json: @subjects.to_json }
    end
  end

  # Params:
  #    ids: subject ids separeted by comas (123,124,53)
  #    at_depth: depth of the children the user wants to retrieve
  #  Returns json:
  #     Danse:
  #           - Salsa
  #           - Zumba
  #           - ...
  #     Cuisine:
  #           - ...
  def descendants
    @subjects = params[:ids].split(',').map{ |id| Subject.find(id) }
    @descendants = {}
    @subjects.each do |parent_subject|
      if params[:at_depth] and params[:at_depth].to_i > 0
        parent_subject.descendants.at_depth(params[:at_depth].to_i).each do |descendant|
          @descendants[descendant.parent.name] ||= []
          @descendants[descendant.parent.name] << descendant
        end
      else
        @descendants[parent_subject.name] = []
        @descendants[parent_subject.name] = parent_subject.descendants
      end
    end
    respond_to do |format|
      if params[:callback]
        format.js { render :json => {descendants: @descendants.to_json}, callback: params[:callback] }
      else
        format.json { render json: @descendants.to_json }
      end
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
